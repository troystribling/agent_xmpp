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
require 'agent_xmpp'
AgentXmpp.logger.level = Logger::INFO

#####-------------------------------------------------------------------------------------------------------
require 'test_delegate'
require 'mocks'
require 'test_client'
require 'matchers'

#####-------------------------------------------------------------------------------------------------------
require 'command_messages'
require 'roster_messages'
require 'service_discovery_messages'
require 'session_messages'

