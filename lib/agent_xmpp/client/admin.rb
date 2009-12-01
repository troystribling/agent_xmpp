#.........................................................................................................
# authorize admin group for command access
#.........................................................................................................
AgentXmpp::BaseController.before :command => %w(contacts) do
  AgentXmpp::Contact.find_by_jid(params[:from])[:groups].include?('admin')
end

#.........................................................................................................
# admin commands
#.........................................................................................................
AgentXmpp::BaseController.command 'contacts', :access => 'admin' do
  AgentXmpp.logger.info "ACTION: contacts"
  # AgentXmpp.Contact.find_all.map{|c| c.delete(:ask); c}
  "it works"
end
