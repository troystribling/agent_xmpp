#####-------------------------------------------------------------------------------------------------------
require 'test/unit'
require 'rubygems'
begin
  require 'shoulda'
rescue LoadError
  abort "shoulda is not available. In order to run test, you must: sudo gem install thoughtbot-shoulda --source=http://gems.github.com"
end
begin
  require 'matchy'
rescue LoadError
  abort "matchy is not available. In order to run test, you must: sudo gem install mhennemeyer-matchy --source=http://gems.github.com"
end

#####-------------------------------------------------------------------------------------------------------
$:.unshift('lib')
require 'rubygems'
require 'agent_xmpp'

#####-------------------------------------------------------------------------------------------------------
require 'test_delegate'
require 'mocks'
require 'test_client'
require 'matchers'
require 'test_case_extensions'

#####-------------------------------------------------------------------------------------------------------
require 'application_messages'
require 'roster_messages'
require 'version_discovery_messages'
require 'service_discovery_messages'
require 'session_messages'
require 'presence_messages'
require 'error_messages'

#####-------------------------------------------------------------------------------------------------------
AgentXmpp.app_path = 'test/helpers'
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

discovered_pubsub_service do |pipe|
  AgentXmpp.logger.info "discovered_pubsub_service"
end

#####-------------------------------------------------------------------------------------------------------
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
  [{:attr1 => 'val11', :attr2 => 'val12'}, {:attr1 => 'val21', :attr2 => 'val22'}, {:attr1 => 'val31', :attr2 => 'val32'}]
end

#.........................................................................................................
execute 'array_hash_array' do
  AgentXmpp.logger.info "ACTION: hash_array"
  [{:attr1 => ['val11', 'val11'], :attr2 => 'val12'}, {:attr1 => ['val21', 'val21'], :attr2 => 'val22'}, {:attr1 => ['val31', 'val31'], :attr2 => 'val32'}]
end
