##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestClientVersionDiscovery < Test::Unit::TestCase

  #.........................................................................................................
  def setup
    @config = {'jid' => 'test@nowhere.com', 'roster' =>['dev@nowhere.com', 'troy@nowhere.com'], 'password' => 'nopass'}
    @client = TestClient.new(@config)
    test_init_roster(@client)
    @delegate = @client.new_delegate
  end
  
  ####-------------------------------------------------------------------------------------------------------
  context "on receiving a presence message of type=available from a jid in configured roster" do
  
    #.........................................................................................................
    setup do
      @delegate.did_receive_version_get_method.should_not be_called
      @delegate.did_receive_version_result_method.should_not be_called
      @client.receiving(PresenceMessages.recv_presence_available(@client, 'troy@nowhere.com/home')).should \
        respond_with(VersionDiscoveryMessages.send_iq_get_query_version(@client, 'troy@nowhere.com/home'))
      @client.receiving(VersionDiscoveryMessages.recv_iq_result_query_version(@client, 'troy@nowhere.com/home')).should not_respond
      @client.roster['troy@nowhere.com'][:resources]['troy@nowhere.com/home'].should_not be_nil
    end  
  
    #.........................................................................................................
    should "send a client version request to that jid and add result version information to roster item" do
      @client.receiving(VersionDiscoveryMessages.recv_iq_result_query_version(@client, 'troy@nowhere.com/home')).should not_respond
      @client.roster['troy@nowhere.com'][:resources]['troy@nowhere.com/home'][:version].should_not be_nil
      @delegate.did_receive_version_result_method.should be_called
      @client.receiving(PresenceMessages.recv_presence_unavailable(@client, 'troy@nowhere.com/home')).should not_respond
    end
    
    #.........................................................................................................
    should "respond to client version requests from that jid" do
      @client.receiving(VersionDiscoveryMessages.recv_iq_get_query_version(@client, 'troy@nowhere.com/home')).should \
        respond_with(VersionDiscoveryMessages.send_iq_result_query_version(@client, 'troy@nowhere.com/home'))
      @delegate.did_receive_version_get_method.should be_called
    end
  
  end
    
  #.........................................................................................................
  should "not respond to client version requests from jids not in configured roster" do
    @delegate.did_receive_version_get_method.should_not be_called
    @client.roster.has_jid?(AgentXmpp::Xmpp::JID.new('noone@nowhere.com')).should be(false)
    @client.receiving(VersionDiscoveryMessages.recv_iq_get_query_version(@client, 'noone@nowhere.com/nothing')).should not_respond
    @delegate.did_receive_version_get_method.should be_called
  end
    
end

