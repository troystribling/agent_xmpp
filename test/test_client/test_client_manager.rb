$:.unshift('lib')
require 'rubygems'
require 'agent_xmpp'
require 'test/test_client/test_client'

##############################################################################################################
class TestClientManager
  
  #.........................................................................................................
  @client = TestClient.new(File.open('test/test_client/test_client.yml') {|yf| YAML::load(yf)})
  
  ####------------------------------------------------------------------------------------------------------
  class << self
    attr_accessor :client
  end
  
#### TestClientManger  
end

