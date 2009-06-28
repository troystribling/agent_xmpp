####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.before_start do

  AgentXmpp.logger.level = Logger::DEBUG
  AgentXmpp.logger.info "AgentXmpp::BootApp.before_start"
  
end

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.after_connected do |pipe|

  AgentXmpp.logger.info "AgentXmpp::BootApp.after_connected"

end

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.restarting_client do |pipe|

  AgentXmpp.logger.info "AgentXmpp::BootApp.restarting_client"

end


