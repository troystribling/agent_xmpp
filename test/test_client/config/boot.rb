####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.after_connection_completed do |connection|

  connection.add_delegate(TestClient)
  AgentXmpp.logger.info "AgentXmpp::BootApp.after_connection_completed"

end

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.restarting_server do |client|

  AgentXmpp.logger.info "AgentXmpp::BootApp.restarting_server"
  break

end
