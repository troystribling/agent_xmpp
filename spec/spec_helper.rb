$:.unshift('lib')
require 'rubygems'
require 'rspec'
require 'agent_xmpp'

#####-------------------------------------------------------------------------------------------------------
Dir.glob('spec/messages/*').each{|f| require File.join(File.dirname(File.expand_path(f)), File.basename(f, '.rb'))}

#####-------------------------------------------------------------------------------------------------------
RSpec.configure do |config|
  config.before(:all) do
  end
end

#####-------------------------------------------------------------------------------------------------------
class ExampleHelper
  
  #.........................................................................................................
  def parse_msg(msg)
    prepared_msg = msg.split(/\n/).inject("") {|p, m| p + m.strip}
    doc = REXML::Document.new(prepared_msg).root
    doc = doc.elements.first if doc.name.eql?('stream')
    if ['presence', 'message', 'iq'].include?(doc.name)
      doc = AgentXmpp::Xmpp::Stanza::import(doc) 
    end
    doc
  end

  #.........................................................................................................
  def new_delegate(client)
    client.remove_delegate(delegate) unless del.nil?
    del = TestDelegate.new
    client.add_delegate(del); del
  end

#### ExampleHelper
end

#####-------------------------------------------------------------------------------------------------------
AgentXmpp.logger.level = Logger::DEBUG

####------------------------------------------------------------------------------------------------------
before_start do
  AgentXmpp.logger.info "AgentXmpp::BootApp.before_start"
end

after_connected do |pipe|
  AgentXmpp.logger.info "AgentXmpp::BootApp.after_connected"
end

restarting_client do |pipe|
  AgentXmpp.logger.info "AgentXmpp::BootApp.restarting_client"
end

discovered_pubsub_node do |service, node|
  AgentXmpp.logger.info "discovered_pubsub_node: #{service}:#{node}"
end

#####-------------------------------------------------------------------------------------------------------
command 'scalar' do
  AgentXmpp.logger.info "ACTION: scalar"
  'scalar' 
end

#.........................................................................................................
command 'hash' do
  AgentXmpp.logger.info "ACTION: hash"
  {:attr1 => 'val1', :attr2 => 'val2'}
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
  [{:attr1 => 'val11', :attr2 => 'val12'}, {:attr1 => 'val21', :attr2 => 'val22'}, {:attr1 => 'val31', :attr2 => 'val32'}]
end

#.........................................................................................................
command 'array_hash_array' do
  AgentXmpp.logger.info "ACTION: hash_array"
  [{:attr1 => ['val11', 'val11'], :attr2 => 'val12'}, {:attr1 => ['val21', 'val21'], :attr2 => 'val22'}, {:attr1 => ['val31', 'val31'], :attr2 => 'val32'}]
end
