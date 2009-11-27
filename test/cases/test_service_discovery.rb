##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestServiceDiscovery < Test::Unit::TestCase

  #.........................................................................................................
  def setup
    @client = TestClient.new()
    test_init_roster(@client)
    @delegate = @client.new_delegate
    @server = AgentXmpp::Xmpp::Jid.new(@client.jid.domain)
    @test = AgentXmpp::Xmpp::Jid.new('test@plan-b.ath.cx/home')
    @noone = AgentXmpp::Xmpp::Jid.new('noone@plan-b.ath.cx/nowhere')
  end

  ####------------------------------------------------------------------------------------------------------
  context "after sesson start a disco#info request addressed to the server should be generated" do
      
    #.........................................................................................................
    setup do
      @delegate.did_receive_discoinfo_result_method.should_not be_called
      ServiceModel.has_disco_info?(@server).should be(false)
      @client.receiving(ServiceDiscoveryMessages.recv_iq_result_query_discoinfo(@client, @server.to_s)).should \
        respond_with(ServiceDiscoveryMessages.send_iq_get_query_discoitems(@client, @server.to_s))
      @delegate.did_receive_discoinfo_result_method.should be_called
      ServiceModel.has_disco_info?(@server).should be(true)
    end
      
    #.........................................................................................................
    should "and the result update the server roster entry and generate a disco#info request if the result is not an error" do
    end
    
    #.........................................................................................................
    should "update the server roster entry with result of server disco#items request if the result is not an error" do
      @delegate.did_receive_discoitems_result_method.should_not be_called
      ServiceModel.has_disco_items?(@server).should be(false)
      @client.receiving(ServiceDiscoveryMessages.recv_iq_result_query_discoitems(@client, @server.to_s)).should not_respond
      @delegate.did_receive_discoitems_result_method.should be_called
      ServiceModel.has_disco_items?(@server).should be(true)
    end
    
    #.........................................................................................................
    should "not update the server roster entry with the disco#items result if the result is an error" do
      @delegate.did_receive_discoitems_result_method.should_not be_called
      @delegate.did_receive_discoitems_error_method.should_not be_called
      ServiceModel.has_disco_items?(@server).should be(false)
      @client.receiving(ServiceDiscoveryMessages.recv_iq_error_query_discoitems(@client, @server.to_s)).should not_respond
      @delegate.did_receive_discoitems_result_method.should_not be_called
      @delegate.did_receive_discoitems_error_method.should be_called
      ServiceModel.has_disco_items?(@server).should be(false)
    end
  
  end  
  
  ####------------------------------------------------------------------------------------------------------
  context "after transition of contact to presence with type=available a disco#info request addressed to the contact should be genearated and the result" do
   
    #.........................................................................................................
    setup do
      AgentXmpp::Xmpp::IdGenerator.set_gen_id([1,2])
      @client.receiving(PresenceMessages.recv_presence_available(@client, @test.to_s))
      @delegate.did_receive_discoinfo_result_method.should_not be_called
      ServiceModel.has_disco_info?(@test).should be(false)
      AgentXmpp::Xmpp::IdGenerator.set_gen_id
      @client.receiving(ServiceDiscoveryMessages.recv_iq_result_query_discoinfo(@client, @test.to_s)).should \
        respond_with(ServiceDiscoveryMessages.send_iq_get_query_discoitems(@client, @test.to_s))
      @delegate.did_receive_discoinfo_result_method.should be_called
      ServiceModel.has_disco_info?(@test).should be(true)
    end
          
    #.........................................................................................................
    should "update the contact roster entry and generate a disco#items request if the result is not an error" do
    end
      
    #.........................................................................................................
    should "update the contact roster entry with result of contact disco#items request if the result is not an error" do
        @delegate.did_receive_discoitems_result_method.should_not be_called
        ServiceModel.has_disco_items?(@test).should be(false)
        @client.receiving(ServiceDiscoveryMessages.recv_iq_result_query_discoitems(@client, @test.to_s)).should not_respond
        @delegate.did_receive_discoitems_result_method.should be_called
        ServiceModel.has_disco_items?(@test).should be(true)
    end
      
    #.........................................................................................................
    should "not update the contact roster entry with the disco#info result or geneate a disco#items request if the result is an error" do
        @delegate.did_receive_discoitems_result_method.should_not be_called
        @delegate.did_receive_discoitems_error_method.should_not be_called
        ServiceModel.has_disco_items?(@test).should be(false)
        @client.receiving(ServiceDiscoveryMessages.recv_iq_error_query_discoitems(@client, @test.to_s)).should not_respond
        @delegate.did_receive_discoitems_result_method.should_not be_called
        @delegate.did_receive_discoitems_error_method.should be_called
        ServiceModel.has_disco_items?(@test).should be(false)
    end
      
  end
  
  #.........................................................................................................
  should "not update the roster entry with the disco#info result or geneate a disco#items request if an error is received as a result of a disco#info request" do
    @delegate.did_receive_discoinfo_result_method.should_not be_called
    @delegate.did_receive_discoinfo_error_method.should_not be_called    
    ServiceModel.has_disco_info?(@server).should be(false)
    @client.receiving(ServiceDiscoveryMessages.recv_iq_error_query_discoinfo(@client, @server.to_s)).should not_respond
    ServiceModel.has_disco_info?(@server).should be(false)
    @delegate.did_receive_discoinfo_result_method.should_not be_called
    @delegate.did_receive_discoinfo_error_method.should be_called    
  end
  
  #.........................................................................................................
  should "respond with features and identity when get disco#info is received without a specified node from a jid in the configuration roster" do
    @delegate.did_receive_discoinfo_get_method.should_not be_called
    @client.receiving(ServiceDiscoveryMessages.recv_iq_get_query_discoinfo(@client, @test.to_s)).should \
      respond_with(ServiceDiscoveryMessages.send_iq_result_query_discoinfo(@client, @test.to_s))
    @delegate.did_receive_discoinfo_get_method.should be_called
  end
  
  #.........................................................................................................
  should "respond with service-unavailable error when get disco#info is received for unsupported node" do
    @delegate.did_receive_discoinfo_get_method.should_not be_called
    @client.receiving(ServiceDiscoveryMessages.recv_iq_get_query_discoinfo_error(@client, @test.to_s)).should \
      respond_with(ServiceDiscoveryMessages.send_iq_error_discoinfo_service_unavailable(@client, @test.to_s))
    @delegate.did_receive_discoinfo_get_method.should be_called
  end
  
  #.........................................................................................................
  should "not respond if get disco#info is received from a jid not in the configuration roster" do
    ContactModel.has_jid?(@noone).should be(false)
    @delegate.did_receive_discoinfo_get_method.should_not be_called
    @client.receiving(ServiceDiscoveryMessages.recv_iq_get_query_discoinfo(@client, @noone.to_s)).should not_respond
    ContactModel.has_jid?(@noone).should be(false)
    @delegate.did_receive_discoinfo_get_method.should be_called
  end
  
  #.........................................................................................................
  should "respond with empty result when get disco#items is received with no specified node from a jid in the configuration roster" do
    @delegate.did_receive_discoitems_get_method.should_not be_called
    @client.receiving(ServiceDiscoveryMessages.recv_iq_get_query_discoitems(@client, @test.to_s)).should \
      respond_with(ServiceDiscoveryMessages.send_iq_result_query_discoitems(@client, @test.to_s))
    @delegate.did_receive_discoitems_get_method.should be_called
  end
  
  #.........................................................................................................
  should "respond with command nodes when get disco#items is received for the node 'http://jabber.org/protocol/commands'" do
    @delegate.did_receive_discoitems_get_method.should_not be_called
    @client.receiving(ServiceDiscoveryMessages.recv_iq_get_query_discoitems_for_commands_node(@client, @test.to_s)).should \
      respond_with(ServiceDiscoveryMessages.send_iq_result_query_discoitems_for_commands_node(@client, @test.to_s))
    @delegate.did_receive_discoitems_get_method.should be_called
  end
  
  #.........................................................................................................
  should "respond with item-not-found error when get disco#items is received for unsupported node" do
    @delegate.did_receive_discoitems_get_method.should_not be_called
    @client.receiving(ServiceDiscoveryMessages.recv_iq_get_query_discoitems_error(@client, @test.to_s)).should \
      respond_with(ServiceDiscoveryMessages.send_iq_error_discoitems_item_not_found(@client, @test.to_s))
    @delegate.did_receive_discoitems_get_method.should be_called
  end
  
  #.........................................................................................................
  should "not respond if get disco#items is received from a jid not in the configuration roster" do
    ContactModel.has_jid?(@noone).should be(false)
    @delegate.did_receive_discoitems_get_method.should_not be_called
    @client.receiving(ServiceDiscoveryMessages.recv_iq_get_query_discoitems(@client, @noone.to_s)).should not_respond
    ContactModel.has_jid?(@noone).should be(false)
    @delegate.did_receive_discoitems_get_method.should be_called
  end
    
end

