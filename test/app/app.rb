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
    EventMachine::PeriodicTimer.new(600) do
      publish_time(Time.now.to_s)
      AgentXmpp.logger.info "FIRING EVENT TIME: #{Time.now.to_s}"
    end  
  end
end

#.........................................................................................................
discovered_command_nodes do |jid, nodes|
  AgentXmpp.logger.info "discovered_command_nodes"
  nodes.each do |n|
    AgentXmpp.logger.info "COMMAND NODE: #{jid}, #{n}"
    send_command(:to=>jid, :node=> n) do |status, data|
      AgentXmpp.logger.info "COMMAND RESPONSE: #{status}, #{data.inspect}"
    end
  end
end

#.........................................................................................................
received_presence do |from, status|
  AgentXmpp.logger.info "received_presence: #{from}, #{status}"
end

##########################################################################################################
# command processing: response payloads
#.........................................................................................................
command 'scalar' do
  AgentXmpp.logger.info "ACTION: scalar"
  'scalar' 
end

#.........................................................................................................
command 'hash' do
  AgentXmpp.logger.info "ACTION: hash"
  {:xyz => 'wuv', :attr1 => 'val1', :attr2 => 'val2', :test1 => 'ans1'}
end

#.........................................................................................................
command 'scalar_array' do
  AgentXmpp.logger.info "ACTION: array"
  ['val1', 'val2','val3', 'val4'] 
end

#.........................................................................................................
command 'hash_array' do
  AgentXmpp.logger.info "ACTION: hash_array"
  {:attr1 => ['val11', 'val11'], :attr2 => 'val12'}
end

#.........................................................................................................
command 'array_hash' do
  AgentXmpp.logger.info "ACTION: array_hash"
  [{:attr1 => 'val11', :attr2 => 'val12'}, 
   {:attr1 => 'val21', :attr2 => 'val22'}, 
   {:attr1 => 'val31', :attr2 => 'val32'}]
end

#.........................................................................................................
command 'array_hash_array' do
  AgentXmpp.logger.info "ACTION: hash_array"
  [{:attr1 => ['val11', 'val11'], :attr2 => 'val12'}, 
   {:attr1 => ['val21', 'val21'], :attr2 => 'val22'}, 
   {:attr1 => ['val31', 'val31'], :attr2 => 'val32'}]
end

##########################################################################################################
# command processing: data forms
#.........................................................................................................
command 'text_single' do
  AgentXmpp.logger.info "ACTION: text_single"
  on(:execute) do |form|
    form.add_title('Your Name')
    form.add_instructions('Use the keyboard to enter your name below.')
    form.add_text_single('name', 'enter your name')
  end
  on(:submit) do
    params[:data]
  end
end

#.........................................................................................................
command 'multiple_text_single' do
  AgentXmpp.logger.info "ACTION: text_single"
  on(:execute) do |form|
    form.add_title('Car and City')
    form.add_instructions('Use the keyboard to enter a car model and a city below.')
    form.add_text_single('car', 'enter car model')
    form.add_text_single('city', 'enter city')
  end
  on(:submit) do
    params[:data]
  end
end

#.........................................................................................................
command 'text_private' do
  AgentXmpp.logger.info "ACTION: text_multi"
  on(:execute) do |form|
    form.add_title('Enter a Secret')
    form.add_instructions('Use the keyboard to enter your secret below.')
    form.add_text_private('secret', 'The Secret')
  end
  on(:submit) do
    params[:data]
  end
end

#.........................................................................................................
command 'jid_single' do
  AgentXmpp.logger.info "ACTION: text_single"
  on(:execute) do |form|
    form.add_title('The JID')
    form.add_instructions('Use the keyboard to enter a JID below.')
    form.add_jid_single('jid', 'A JID')
  end
  on(:submit) do
    params[:data]
  end
end

#.........................................................................................................
command 'text_multi' do
  AgentXmpp.logger.info "ACTION: text_multi"
  on(:execute) do |form|
    form.add_title('Tell a Story')
    form.add_instructions('Use the keyboard to enter your story below.')
    form.add_text_multi('story', 'Your Story')
  end
  on(:submit) do
    params[:data]
  end
end

#.........................................................................................................
command 'list_single' do
  AgentXmpp.logger.info "ACTION: list_single"
  on(:execute) do |form|
    form.add_title('Fruits')
    form.add_instructions('Select a fruit from the list.')
    form.add_list_single('fruits', [:apple, :orange, :lemon, :lime, :kiwi_fruit], 'available fruits')
  end
  on(:submit) do
    params[:data]
  end
end

#.........................................................................................................
command 'boolean' do
  AgentXmpp.logger.info "ACTION: list_single"
  on(:execute) do |form|
    form.add_title('On or Off')
    form.add_instructions('Choose below')
    form.add_boolean('answer', 'On or Off please')
  end
  on(:submit) do
    params[:data]
  end
end

#.........................................................................................................
command 'long_form' do
  AgentXmpp.logger.info "ACTION: list_single"
  on(:execute) do |form|
    form.add_title('The Long Form')
    form.add_instructions('Make the correct choices and provide the required information.')
    form.add_fixed("Make the correct choices.")
    form.add_list_single('fruits', [:apple, :orange, :lemon, :lime, :kiwi_fruit], 'Select a Fruit')
    form.add_list_single('nuts', [:peanut, :almond, :cashew, :pecan, :walnut], 'Select a Nut')
    form.add_list_single('vegetables', [:broccoli, :carrot, :corn, :tomato, :onion], 'Select a Nut')
    form.add_fixed("Your name is required.")
    form.add_text_single('first_name', 'First Name')
    form.add_text_single('last_name', 'Last Name')
    form.add_fixed("Your address is required.")
    form.add_text_single('street', 'Street')
    form.add_text_single('city', 'City')
    form.add_text_single('state', 'State')
    form.add_text_single('zip', 'Zip Code')
    form.add_fixed("Your password is required.")
    form.add_text_private('password', 'Password')
    form.add_text_private('renter_password', 'Renter Password')
    form.add_fixed("A story is required.")
    form.add_text_multi('story', 'Your Story')
  end
  on(:submit) do
    params[:data]
  end
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
event 'test@planbresearch.com', 'val' do
  AgentXmpp.logger.info "EVENT: test@planbresearch.com/val"
  send_chat(:to=>params[:from], :body=>"Got the event at: " + Time.now.to_s)
end

#.........................................................................................................
event 'test@planbresearch.com', 'waiting' do
  AgentXmpp.logger.info "EVENT: test@planbresearch.com/waiting"
  p params
end
