$:.unshift('lib')
require 'rubygems'
require 'rspec'
require 'agent_xmpp'

#####-------------------------------------------------------------------------------------------------------
Dir.glob('spec/messages/*').each{|f| require File.join(File.dirname(File.expand_path(f)), File.basename(f, '.rb'))}
require 'test_delegate'
require 'matchers'

#####-------------------------------------------------------------------------------------------------------
RSpec.configure do |config|
  config.before(:all) do
    @agent = 'agent@nowhere.com'
    @admin = 'troy@somewhere.com'
    @user = 'vanessa@there.com'
    config = {'jid'      => @agent, 
              'password' => 'pass', 
              'roster'   => [{'jid' => @admin, 'groups' => ['admin']}, 
                             {'jid' => @user, 'groups' => ['user']}]
             }
  AgentXmpp.config = config
  AgentXmpp.drop_tables_in_memory_db
  AgentXmpp.drop_tables_agent_xmpp_db
  AgentXmpp.create_agent_xmpp_db  
  AgentXmpp.create_in_memory_db        
  AgentXmpp.upgrade_agent_xmpp_db
  AgentXmpp::Contact.load_config 
  AgentXmpp::Publication.load_config  
  end
  config.before(:each) do
    AgentXmpp::Xmpp::IdGenerator.set_gen_id
  end
end

#####-------------------------------------------------------------------------------------------------------
class SpecUtils 

  #.........................................................................................................
  def self.parse_stanza(stanza)
    prepared_stanza = stanza.split(/\n/).inject("") {|p, m| p + m.strip}
    doc = REXML::Document.new(prepared_stanza).root
    doc = doc.elements.first if doc.name.eql?('stream')
    if ['presence', 'message', 'iq'].include?(doc.name)
      doc = AgentXmpp::Xmpp::Stanza::import(doc) 
    end; doc
  end

  #.........................................................................................................
  def self.prepare_msg(msg)
    msg.collect{|i| i.split(/\n+/).inject("") {|p, m| p + m.strip.gsub(/\s+/, " ")}}
  end

#### SpecUtils
end

#####-------------------------------------------------------------------------------------------------------
module AgentXmpp
  module Xmpp
    class IdGenerator
      @gen_id;
      class << self
        def set_gen_id(val=1); @gen_id = val; end
        def gen_id; @gen_id; end;
        def generate_id; @gen_id.kind_of?(Array) ? @gen_id.shift : @gen_id; end
      end
    end
  end
end

#####-------------------------------------------------------------------------------------------------------
class AgentXmpp::Boot  
  def self.boot     
  end        
end

#####-------------------------------------------------------------------------------------------------------
AgentXmpp.logger.level = Logger::DEBUG
AgentXmpp.app_path = 'spec'

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
