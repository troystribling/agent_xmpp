##########################################################################################################
require 'rubygems'
require "#{File.dirname(__FILE__)}/../../lib/agent_xmpp"

##########################################################################################################
before_start do
  AgentXmpp.logger.level = Logger::DEBUG
  AgentXmpp.logger.info "before_start"
end

#.........................................................................................................
after_connected do |pipe|
  AgentXmpp.logger.info "after_connected"
end

#.........................................................................................................
restarting_client do |pipe|
  AgentXmpp.logger.info "restarting_client"
end

#.........................................................................................................
discovered_all_publish_nodes do |pipe|
  AgentXmpp.logger.info "discovered_publish_nodes"
  EventMachine::PeriodicTimer.new(60) do
    tnow = Time.now.to_s
    publish_time(tnow)
    AgentXmpp.logger.info "FIRING EVENT: #{tnow}"
  end  
end

#.........................................................................................................
discovered_pubsub_node do |pipe, service, node|
  AgentXmpp.logger.info "discovered_pubsub_node: #{service}, #{node}"
end

#.........................................................................................................
discovered_command_nodes do |pipe, nodes|
  AgentXmpp.logger.info "discovered_command_nodes"
  nodes.each do |n|
    AgentXmpp.logger.info "NODE: #{n.jid}, #{n.node}"
  end
end

##########################################################################################################
execute 'scalar' do
  AgentXmpp.logger.info "ACTION: scalar"
  'scalar' 
end

#.........................................................................................................
execute 'hash' do
  AgentXmpp.logger.info "ACTION: hash"
  {:attr1 => 'val1', :attr2 => 'val2'}
end

#.........................................................................................................
execute 'scalar_array' do
  AgentXmpp.logger.info "ACTION: array"
  ['val1', 'val2','val3', 'val4'] 
end

#.........................................................................................................
execute 'hash_array' do
  AgentXmpp.logger.info "ACTION: hash_array"
  {:attr1 => ['val11', 'val11'], :attr2 => 'val12'}
end

#.........................................................................................................
execute 'array_hash' do
  AgentXmpp.logger.info "ACTION: array_hash"
  [{:attr1 => 'val11', :attr2 => 'val12'}, 
   {:attr1 => 'val21', :attr2 => 'val22'}, 
   {:attr1 => 'val31', :attr2 => 'val32'}]
end

#.........................................................................................................
execute 'array_hash_array' do
  AgentXmpp.logger.info "ACTION: hash_array"
  [{:attr1 => ['val11', 'val11'], :attr2 => 'val12'}, 
   {:attr1 => ['val21', 'val21'], :attr2 => 'val22'}, 
   {:attr1 => ['val31', 'val31'], :attr2 => 'val32'}]
end

##########################################################################################################
event 'test@planbresearch.com', 'val' do
  AgentXmpp.logger.info "EVENT: test@planbresearch.com/val"
  p params
end

#.........................................................................................................
event 'test@planbresearch.com', 'waiting' do
  AgentXmpp.logger.info "EVENT: test@planbresearch.com/waiting"
  p params
end

#.........................................................................................................
event 'test@plan-b.ath.cx', 'val' do
  AgentXmpp.logger.info "EVENT: test@plan-b.ath.cx/val"
  p params
end
