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
require 'service_discovery_messages'
require 'session_messages'
require 'presence_messages'

#####-------------------------------------------------------------------------------------------------------
AgentXmpp.app_path = 'test/test_app'
AgentXmpp.config_file = 'config/test_agent.yml'
AgentXmpp::Boot.boot

