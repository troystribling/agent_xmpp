require 'test/unit'
require 'rubygems'
begin
  require 'shoulda'
rescue LoadError
  abort "shoulda is not available. In order to run test, you must: sudo gem install thoughtbot-shoulda --source=http://gems.github.com"
end
require 'agent_xmpp'
require 'test/test_client/stub_connection'
require 'test_message_helper'

##############################################################################################################
require 'test_helper'

##############################################################################################################
class Test::Unit::TestCase

end
