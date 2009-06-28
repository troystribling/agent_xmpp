####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.after_connected do |pipe|

  pipe.add_delegate(TestClient)
  AgentXmpp.logger.info "AgentXmpp::BootApp.after_connection_completed"

end

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.restarting_client do |pipe|

  AgentXmpp.logger.info "AgentXmpp::BootApp.restarting_server"

end
