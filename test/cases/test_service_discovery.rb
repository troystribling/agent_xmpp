##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestServiceDiscovery < Test::Unit::TestCase

  #.........................................................................................................
  def setup
    @client = TestClient.new()
    test_init_roster(@client)
    @delegate = @client.new_delegate
    @server = AgentXmpp::Xmpp::JID.new(@client.jid.domain)
  end

  ####------------------------------------------------------------------------------------------------------
  context "on sesson start request disco#items from server" do
  
    #.........................................................................................................
    setup do
      @delegate.did_receive_discoinfo_result_method.should_not be_called
      @client.roster.has_discoinfo?(@server).should be(false)
      @client.receiving(ServiceDiscoveryMessages.recv_iq_result_query_discoinfo(@client, @server.to_s)).should \
        respond_with(ServiceDiscoveryMessages.send_iq_get_query_discoitems(@client, @server.to_s))
      @delegate.did_receive_discoinfo_result_method.should be_called
      @client.roster.has_discoinfo?(@server).should be(true)
    end
  
    #.........................................................................................................
    should "update roster with result of server disco#info request and request disco#items" do
    end

    # #.........................................................................................................
    # should "update roster with result of server disco#items request" do
    # end
    # 

    # #.........................................................................................................
    # should "should not update roster or request disco#items when an error is received in response to  disco#info request" do
    # end
    #   

  end
  
  # ####------------------------------------------------------------------------------------------------------
  # context "on transtition of contact to avialable request request disco#items from contact" do
  #   
  #   #.........................................................................................................
  #   should "update roster with result of contact disco#info request and resquest disco#items" do
  #   end
  # 
  #   #.........................................................................................................
  #   should "should not update roster or request disco#items when an error is received in response to  disco#info request" do
  #   end
  #     
  # 
  #   #.........................................................................................................
  #   should "update roster with result of contact disco#items request" do
  #   end
  # 
  # end
  #
  # #.........................................................................................................
  # should "respond with features and identity when get disco#info is received with no specified node" do
  # end
  # 
  # #.........................................................................................................
  # should "respond with features and identity when get disco#info is received with no specified node" do
  # end
  # 
  # #.........................................................................................................
  # should "respond with empty result when get disco#info is received for unsupported node" do
  # end
  # 
  # #.........................................................................................................
  # should "respond with service-unavailable error when get disco#info is received for unsupported node" do
  # end
  # 
  # #.........................................................................................................
  # should "respond with empty result when get disco#items is received with no specified node" do
  # end
  # 
  # #.........................................................................................................
  # should "respond with command nodes when get disco#items is received for the node 'http://jabber.org/protocol/commands'" do
  # end
  # 
  # #.........................................................................................................
  # should "respond with item-not-found error when get disco#items is received for unsupported node" do
  # end
  
end

