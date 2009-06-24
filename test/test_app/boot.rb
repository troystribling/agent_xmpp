####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.before_start do

  AgentXmpp.logger.info "AgentXmpp::BootApp.before_start"
  
end

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.after_connected do |pipe|

  AgentXmpp.logger.info "AgentXmpp::BootApp.after_connected"

end

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.restarting_server do |pipe|

  AgentXmpp.logger.info "AgentXmpp::BootApp.restarting_server"

end


