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
discovered_user_pubsub_node do |pipe|
  AgentXmpp.logger.info "discovered_user_pubsub_node"
  EventMachine::PeriodicTimer.new(60) do
    tnow = Time.now.to_s
    publish_time(tnow.to_x_data)
    AgentXmpp.logger.info "FIRING EVENT: #{tnow}"
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
event 'test@plan-b.ath.cx', 'val' do
  AgentXmpp.logger.info "EVENT: val"
  p params[:data]
end
