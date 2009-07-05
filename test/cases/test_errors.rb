##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestErrors < Test::Unit::TestCase

  #.........................................................................................................
  def setup
    @client = TestClient.new()
    test_init_roster(@client)
    @delegate = @client.new_delegate
  end
  
  #.........................................................................................................
  should "respond with feature-not-implemented when unsupported messages are received" do
  end

  
end

