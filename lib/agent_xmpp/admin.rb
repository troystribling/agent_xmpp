#.........................................................................................................
# authorize command access
#.........................................................................................................
before :command => :all do
  if access = route[:opts][:access]
    groups = AgentXmpp::Contact.find_by_jid(params[:from])[:groups] 
    [access].flatten.any?{|a| groups.include?(a)}
  else; true; end
end

#.........................................................................................................
# admin commands
#.........................................................................................................
command 'admin/contacts', :access => 'admin' do
  AgentXmpp.logger.info "ACTION: admin/contacts"
  AgentXmpp::Contact.find_all.map{|c| {:jid => c[:jid], :sub => c[:subscription]}}
end

#.........................................................................................................
command 'admin/on_line_users', :access => 'admin' do
  AgentXmpp.logger.info "ACTION: admin/on_line_users"
  AgentXmpp::Roster.find_all_by_status(:available).map do |r| 
    jid = AgentXmpp::Xmpp::Jid.new(r[:jid]) 
    {:jid => jid.bare, :resource => jid.resource}
  end
end

#.........................................................................................................
command 'admin/add_contact', :access => 'admin' do
  AgentXmpp.logger.info "ACTION: admin/add_contact"
  on(:execute) do |form|
    form.add_title('Add Contact')
    form.add_jid_single('jid', 'contact JID')
    form.add_text_single('groups', 'groups comma seperated')
  end
  on(:submit) do
    contact = params[:data]
    if contact["jid"]
      AgentXmpp::Contact.update(contact)
      pipe.send_resp([AgentXmpp::Xmpp::IqRoster.update(pipe, contact["jid"], contact["groups"].split(/,/)), 
                      AgentXmpp::Xmpp::Presence.subscribe(contact["jid"])]) 
      defer() do
      end 
      defer() do
      end               
    else
      error(:bad_request, 'jid not specified')
    end
  end
end

#.........................................................................................................
command 'admin/delete_contact', :access => 'admin' do
  AgentXmpp.logger.info "ACTION: admin/delete_contact"
  contacts = AgentXmpp::Contact.find_all.map{|c| c[:jid]}
  on(:execute) do |form|
    form.add_title('Delete Contact')
    form.add_list_single('jid', contacts)
  end
  on(:submit) do
    contact = params[:data]
    if contact["jid"]
      pipe.send_resp(AgentXmpp::Xmpp::IqRoster.remove(pipe, contact["jid"]))  
      defer() do
      end 
      defer() do
      end               
    else
      error(:bad_request, 'jid not specified')
    end
  end
end

#.........................................................................................................
command 'admin/subscriptions', :access => 'admin' do
  AgentXmpp.logger.info "ACTION: admin/subscriptions"
  AgentXmpp::Subscription.find_all.map{|s| {:node => s[:node].split("/")[2..-1].join("/"), :count => 0, :last => '1/1/09 12:00'}}
end

#.........................................................................................................
command 'admin/publications', :access => 'admin' do
  AgentXmpp.logger.info "ACTION: admin/publications"
  AgentXmpp::Publication.find_all.map{|p| {:node => p[:node], :count => 0, :last => '1/1/09 12:00'}}
end

#.........................................................................................................
command 'admin/message stats', :access => 'admin' do
  AgentXmpp.logger.info "ACTION: admin/publications"
end

#.........................................................................................................
command 'admin/contact stats', :access => 'admin' do
  AgentXmpp.logger.info "ACTION: admin/publications"
end
