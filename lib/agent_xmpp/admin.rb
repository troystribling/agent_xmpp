#.........................................................................................................
# authorize command access
#.........................................................................................................
before :command => :all do
  if access = route[:opts][:access]
    jid = params[:from]    
    unless AgentXmpp.is_account_jid?(jid)
      groups = AgentXmpp::Contact.find_by_jid(jid)[:groups] 
      [access].flatten.any?{|a| groups.include?(a)}
    else; true; end
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
command 'admin/online_users', :access => 'admin' do
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
      xmpp_msg(AgentXmpp::Xmpp::IqRoster.update(pipe, contact["jid"], contact["groups"].split(/,/))) 
      xmpp_msg(AgentXmpp::Xmpp::Presence.subscribe(contact["jid"]))
      delegate_to(
        :on_update_roster_item_result => lambda do |pipe, item_jid|     
          command_completed if item_jid.eql?(contact["jid"])
        end,
        :on_update_roster_item_error  => lambda do |pipe, item_jid|
          error(:bad_request, params, 'roster updated failed') if item_jid.eql?(contact["jid"])
        end
      )
    else
      error(:bad_request, params, 'jid not specified')
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
      xmpp_msg(AgentXmpp::Xmpp::IqRoster.remove(pipe, contact["jid"]))  
      delegate_to(
        :on_remove_roster_item_result => lambda do |pipe, item_jid|           
          command_completed if item_jid.eql?(contact["jid"])
        end,
        :on_remove_roster_item_error  => lambda do |pipe, item_jid|
          error(:bad_request, params, 'roster updated failed') if item_jid.eql?(contact["jid"])
        end
      )
    else
      error(:bad_request, params, 'jid not specified')
    end
  end
end

#.........................................................................................................
command 'admin/subscriptions', :access => 'admin' do
  AgentXmpp.logger.info "ACTION: admin/subscriptions"
  AgentXmpp::Subscription.stats_by_node    
end

#.........................................................................................................
command 'admin/publications', :access => 'admin' do
  AgentXmpp.logger.info "ACTION: admin/publications"
  AgentXmpp::Publication.stats_by_node
end

#.........................................................................................................
command 'admin/messages_by_type', :access => 'admin' do
  AgentXmpp.logger.info "ACTION: admin/publications"
  AgentXmpp::Message.stats_by_message_type
end

#.........................................................................................................
command 'admin/messages_by_contact', :access => 'admin' do
  AgentXmpp.logger.info "ACTION: admin/publications"
  AgentXmpp::Contact.message_stats
end

#.........................................................................................................
command 'admin/messages_by_command', :access => 'admin' do
  AgentXmpp.logger.info "ACTION: admin/publications"
  AgentXmpp::Message.stats_by_command_node
end
