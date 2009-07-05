##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestServiceDiscovery < Test::Unit::TestCase

  #.........................................................................................................
  def setup
    @client = TestClient.new()
    test_init_roster(@client)
    @delegate = @client.new_delegate
  end

  #.........................................................................................................
  def test_receive_discoinfo(client)
    delegate = client.new_delegate
    delegate.did_receive_roster_item_method.should_not be_called
    yield client
    delegate.did_receive_roster_item_method.should be_called
    delegate.did_receive_all_roster_items_method.should be_called     
  end
  
  #.........................................................................................................
  should "respond with features and identity when get disco#info is received with no specified node" do
  end

  #.........................................................................................................
  should "respond with empty result when get disco#info is received for unsupported node" do
  end

  #.........................................................................................................
  should "respond with service-unavailable error when get disco#info is received for unsupported node" do
  end

  #.........................................................................................................
  should "respond with empty result when get disco#items is received with no specified node" do
  end

  #.........................................................................................................
  should "respond with command nodes when get disco#items is received for the node 'http://jabber.org/protocol/commands'" do
  end
  
  #.........................................................................................................
  should "respond with item-not-found error when get disco#items is received for unsupported node" do
  end
  
end

