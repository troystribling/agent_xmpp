##########################################################################################################
require 'rubygems'
require "#{File.dirname(__FILE__)}/../../lib/agent_xmpp"

##########################################################################################################
# callbacks
before_start do 
  AgentXmpp.logger.level = Logger::WARN
  File.delete("#{AgentXmpp.app_path}/in_memory.db") if File.exists?("#{AgentXmpp.app_path}/in_memory.db")
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
puts "service:#{service}, node:#{node}"  
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
    form.add_fixed('State of residence')
    form.add_text_single('state')
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
    form.add_fixed('Renter your secret')
    form.add_text_private('another_secret')
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
    form.add_fixed("Another JID")
    form.add_jid_single('another_jid')
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
    form.add_fixed("A haiku is required")
    form.add_text_multi('haiku')
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
    form.add_fixed('Choose a car')
    form.add_list_single('car', [:audi_s4, :bmw_m3, :subaru_wrx_ti, :mitsubishi_evo])
  end
  on(:submit) do
    params[:data]
  end
end

#.........................................................................................................
command 'boolean' do
  AgentXmpp.logger.info "ACTION: boolean"
  on(:execute) do |form|
    form.add_title('Hyper Drive Configuration')
    form.add_instructions('Choose the hyperdrive configuration which best suits your needs')
    form.add_boolean('answer', 'On or Off please')
    form.add_boolean('flux_capcitors', 'Enable flux capacitors for superluminal transport')
    form.add_fixed('Enable SQUIDs for enhanced quantum decoherence')
    form.add_boolean('squids')
  end
  on(:submit) do
    params[:data]
  end
end

#.........................................................................................................
command 'long_form' do
  AgentXmpp.logger.info "ACTION: long_form"
  on(:execute) do |form|
    form.add_title('The Long Form')
    form.add_instructions('Make the correct choices and provide the required information.')
    form.add_fixed("Your name is required.")
    form.add_text_single('first_name', 'First Name')
    form.add_text_single('last_name', 'Last Name')
    form.add_fixed("Your address is required.")
    form.add_text_single('street', 'Street')
    form.add_text_single('city', 'City')
    form.add_text_single('state', 'State')
    form.add_text_single('zip', 'Zip Code')
    form.add_fixed("Enter two friends.")
    form.add_jid_single('contact_1', 'contact JID')
    form.add_jid_single('contact_2', 'contact JID')
    form.add_fixed("Your password is required.")
    form.add_text_private('password', 'Password')
    form.add_text_private('renter_password', 'Renter Password')
    form.add_fixed("Choose your food.")
    form.add_list_single('fruits', [:apple, :orange, :lemon, :lime, :kiwi_fruit], 'Select a Fruit')
    form.add_list_single('nuts', [:peanut, :almond, :cashew, :pecan, :walnut], 'Select a Nut')
    form.add_list_single('vegetables', [:broccoli, :carrot, :corn, :tomato, :onion], 'Select a Vegtable')
    form.add_fixed("Answer the questions.")
    form.add_boolean('yes_or_no', 'Yes or No please?')
    form.add_boolean('flux_capcitors', 'Enable flux capacitors for superluminal transport')
    form.add_fixed("A story of at least 250 characters is required")
    form.add_text_multi('story', 'Your Story')
  end
  on(:submit) do
    params[:data]
  end
end

#.........................................................................................................
command 'another_long_form' do
  AgentXmpp.logger.info "ACTION: another_long_form"
  on(:execute) do |form|
    form.add_title('The Other Long Form')
    form.add_instructions('Make the correct choices and provide the required information')
    form.add_fixed("Your nickname is required.")
    form.add_text_single('nickname', 'Nickname')
    form.add_fixed
    form.add_text_single('street', 'Street')
    form.add_text_single('city', 'City')
    form.add_text_single('state', 'State')
    form.add_text_single('zip', 'Zip Code')
    form.add_fixed("Your password is required.")
    form.add_text_private('password', 'Password')
    form.add_text_private('renter_password', 'Renter Password')
    form.add_fixed("A haiku is required")
    form.add_text_multi('haiku')
    form.add_fixed("A limerick is required")
    form.add_text_multi('limericck')
    form.add_fixed("A story of at least 250 characters is required.")
    form.add_text_multi('story', 'Your Story')
  end
  on(:submit) do
    params[:data]
  end
end

#.........................................................................................................
command 'no_title' do
  AgentXmpp.logger.info "ACTION: no_title"
  on(:execute) do |form|
    form.add_instructions('Choose On or Off')
    form.add_boolean('answer', 'On or Off please')
  end
  on(:submit) do
    params[:data]
  end
end

#.........................................................................................................
command 'no_instructions' do
  AgentXmpp.logger.info "ACTION: no_instructions"
  on(:execute) do |form|
    form.add_title('Yes or No')
    form.add_boolean('answer', 'Yes or No please')
  end
  on(:submit) do
    params[:data]
  end
end

#.........................................................................................................
command 'text_view_with_jids' do
  AgentXmpp.logger.info "ACTION: text_view_with_jids"
  on(:execute) do |form|
    form.add_title('Account Information')
    form.add_instructions('Enter and Account below and provide a description')
    form.add_jid_single('jid', 'account JID')
    form.add_text_multi('description', 'Description of Account')
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
# event 'nowhere@noone.com', 'val' do
#   AgentXmpp.logger.info "EVENT: nowhere@noone.com/val"
#   send_chat(:to=>params[:from], :body=>"Got the event at: " + Time.now.to_s)
# end

#.........................................................................................................
event 'troy@plan-b.ath.cx', 'stupid' do
  AgentXmpp.logger.info "EVENT: troy@plan-b.ath.cx/stupid"
  p params
end

#.........................................................................................................
event 'peer@agentxmpp.org', 'time' do
  AgentXmpp.logger.info "EVENT: peer@agentxmpp.org/time"
  p params
end
