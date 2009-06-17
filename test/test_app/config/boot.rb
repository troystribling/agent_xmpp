####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.before_config_load do

  AgentXmpp.logger.info "AgentXmpp::BootApp.on_app_start"
  
end

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.before_app_load do

  AgentXmpp.logger.info "AgentXmpp::BootApp.before_app_load"
  
end

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.after_app_load do

  AgentXmpp.logger.level = Logger::DEBUG
  AgentXmpp.logger.info "AgentXmpp::BootApp.after_app_load"
  
end

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.after_connection_completed do |connection|

  AgentXmpp.logger.info "AgentXmpp::BootApp.after_connection_completed"

end

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.restarting_server do |client|

  AgentXmpp.logger.info "AgentXmpp::BootApp.restarting_server"

end


