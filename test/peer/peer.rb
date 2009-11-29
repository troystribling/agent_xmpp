##########################################################################################################
require 'rubygems'
require "#{File.dirname(__FILE__)}/../../lib/agent_xmpp"

##########################################################################################################
before_start do
  AgentXmpp.logger.level = Logger::DEBUG
  AgentXmpp.logger.info "before_start"
end

#.........................................................................................................
discovered_pubsub_node do |service, node|
  AgentXmpp.logger.info "discovered_pubsub_node: #{service}, #{node}"
  if node.eql?(AgentXmpp.user_pubsub_root+'/time')
    AgentXmpp.logger.info "LAUNCHING TIME PUBLISH TASK"
    EventMachine::PeriodicTimer.new(30) do
      publish_time({:time => Time.now.to_s, :greeting => 'Rockin'})
      AgentXmpp.logger.info "FIRING EVENT TIME: #{Time.now.to_s}"
    end  
  end
end
