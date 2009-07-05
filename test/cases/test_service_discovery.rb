##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestServiceDiscovery < Test::Unit::TestCase

  #.........................................................................................................
  def setup
    @config = {'jid' => 'test@nowhere.com', 'roster' =>['dev@nowhere.com', 'troy@nowhere.com'], 'password' => 'nopass'}
    @client = TestClient.new(@config)
    AgentXmpp::Xmpp::IdGenerator.init_gen_id
    test_init_roster(@client)
    @delegate = @client.new_delegate
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

