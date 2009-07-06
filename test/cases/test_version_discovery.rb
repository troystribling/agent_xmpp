##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestClientVersionDiscovery < Test::Unit::TestCase

  #.........................................................................................................
  def setup
    @troy = AgentXmpp::Xmpp::JID.new('troy@nowhere.com/home')
    @noone = AgentXmpp::Xmpp::JID.new('noone@nowhere.com/nothing')
    @config = {'jid' => 'test@nowhere.com', 'roster' =>[@troy.bare.to_s], 'password' => 'nopass'}
    @client = TestClient.new(@config)
    test_init_roster(@client)
    @delegate = @client.new_delegate
  end
  
  ####-------------------------------------------------------------------------------------------------------
  context "on receiving a presence message of type=available from a jid in configured roster" do
  
    #.........................................................................................................
    setup do
      AgentXmpp::Xmpp::IdGenerator.set_gen_id([1,2])
      @delegate.did_receive_version_get_method.should_not be_called
      @delegate.did_receive_version_result_method.should_not be_called
      @client.roster.resource(@troy).should be_nil
      @client.receiving(PresenceMessages.recv_presence_available(@client, @troy.to_s)).should \
        respond_with(VersionDiscoveryMessages.send_iq_get_query_version(@client, @troy.to_s))
      @client.roster.resource(@troy).should_not be_nil
      @client.receiving(VersionDiscoveryMessages.recv_iq_result_query_version(@client, @troy.to_s)).should not_respond
      @client.roster.has_version?(@troy).should be(true)
      @delegate.did_receive_version_result_method.should be_called
    end  
  
    #.........................................................................................................
    should "send a client version request to that jid and update roster with result version information" do
    end
    
    #.........................................................................................................
    should "respond to client version requests from that jid" do
      @client.receiving(VersionDiscoveryMessages.recv_iq_get_query_version(@client, @troy.to_s)).should \
        respond_with(VersionDiscoveryMessages.send_iq_result_query_version(@client, @troy.to_s))
      @delegate.did_receive_version_get_method.should be_called
    end
      
  end
    
  #.........................................................................................................
  should "not respond to client version requests from jids not in configured roster" do
    @delegate.did_receive_version_get_method.should_not be_called
    @client.roster.has_jid?(@noone).should be(false)
    @client.receiving(VersionDiscoveryMessages.recv_iq_get_query_version(@client, @noone.to_s)).should not_respond
    @delegate.did_receive_version_get_method.should be_called
  end
    
end

