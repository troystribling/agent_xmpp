##########################################################################################################
require 'rubygems'
require "#{File.dirname(__FILE__)}/../../lib/agent_xmpp"

##########################################################################################################
# callbacks
before_start do 
  AgentXmpp.logger.level = Logger::DEBUG
  AgentXmpp.logger.info "before_start"
end

#.........................................................................................................
after_connected do |connection|
  AgentXmpp.logger.info "after_connected"
end

#.........................................................................................................
restarting_client do |connection|
  AgentXmpp.logger.info "restarting_client"
end

#.........................................................................................................
discovered_pubsub_node do |service, node|
  AgentXmpp.logger.info "discovered_pubsub_node: #{service}, #{node}"
  if node.eql?(AgentXmpp.user_pubsub_root+'/time')
    AgentXmpp.logger.info "LAUNCHING TIME PUBLISH TASK"
    EventMachine::PeriodicTimer.new(60) do
      publish_time(Time.now.to_s)
      AgentXmpp.logger.info "FIRING EVENT TIME: #{Time.now.to_s}"
    end  
  elsif node.eql?(AgentXmpp.user_pubsub_root+'/shot')
    AgentXmpp.logger.info "LAUNCHING SHOT PUBLISH TASK"
    EventMachine::Timer.new(30) do
      publish_shot(Time.now.to_s)
      AgentXmpp.logger.info "FIRING EVENT SHOT: #{Time.now.to_s}"
    end  
  end
end

#.........................................................................................................
discovered_command_nodes do |jid, nodes|
  AgentXmpp.logger.info "discovered_command_nodes"
  nodes.each do |n|
    AgentXmpp.logger.info "COMMAND NODE: #{jid}, #{n}"
    command(:to=>jid, :node=> n) do |status, data|
      AgentXmpp.logger.info "COMMAND RESPONSE: #{status}, #{data.inspect}"
    end
  end
end

#.........................................................................................................
received_presence do |from, status|
  AgentXmpp.logger.info "received_presence: #{from}, #{status}"
end

##########################################################################################################
# command processing
#.........................................................................................................
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

#.........................................................................................................
# respond with a result and another command resquest
execute 'hash_hello' do
  AgentXmpp.logger.info "ACTION: hash_hello"
  command(:to=>params[:from], :node=> 'hello') do |status, data|
    AgentXmpp.logger.info "COMMAND RESPONSE: #{status}, #{data.inspect}"
  end
  {:attr1 => 'val1', :attr2 => 'val2'}
end

##########################################################################################################
# chat messages
chat do
  AgentXmpp.logger.info "CHAT MESSAGE: #{params[:from]}, #{params[:body]}"
  params[:body].reverse  
end

##########################################################################################################
# pubsub events
#.........................................................................................................
# respond with a chat message
event 'test@planbresearch.com', 'val' do
  AgentXmpp.logger.info "EVENT: test@planbresearch.com/val"
  message(:to=>params[:from], :body=>"Got the event at: " + Time.now.to_s)
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
