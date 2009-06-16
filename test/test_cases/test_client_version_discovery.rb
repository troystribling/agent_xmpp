##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestClientVersionDiscovery < Test::Unit::TestCase

  #.........................................................................................................
  def get_client_version
    @client.receiving(PresenceMessages.recv_presence_available(@client, 'troy@nowhere.com/home')).should \
      respond_with(SystemDiscoveryMessages.send_client_version_get(@client, 'troy@nowhere.com/home'))
    @client.receiving(SystemDiscoveryMessages.recv_client_version_result(@client, 'troy@nowhere.com/home')).should not_respond
  end  

  ####-------------------------------------------------------------------------------------------------------
  context "a specified client configuration" do
  
    #.........................................................................................................
    setup do
      @config = {'jid' => 'test@nowhere.com', 'contacts' =>['dev@nowhere.com', 'troy@nowhere.com'], 'password' => 'nopass'}
      @client = TestClient.new(@config)
      test_init_roster(@client, @config)
      @delegate = @client.new_delegate
    end
    
    #.........................................................................................................
    should "send a client version request upon receiving a contact presence message with type=available from a jid and add information to roster item " do
      @delegate.did_receive_client_version_result_method.should_not be_called
      get_client_version
      @client.receiving(SystemDiscoveryMessages.recv_client_version_result(@client, 'troy@nowhere.com/home')).should not_respond
      @client.roster['troy@nowhere.com'][:resources]['troy@nowhere.com/home'][:version].should_not be_nil
      @delegate.did_receive_client_version_result_method.should be_called
      @client.receiving(PresenceMessages.recv_presence_unavailable(@client, 'troy@nowhere.com/home')).should not_respond
    end
    
    #.........................................................................................................
    should "respond to client version requests from jids in configured roster" do
      @delegate.did_receive_client_version_request_method.should_not be_called
      get_client_version
      @client.roster['troy@nowhere.com'][:resources]['troy@nowhere.com/home'].should_not be_nil
      @client.receiving(SystemDiscoveryMessages.recv_client_version_get(@client, 'troy@nowhere.com/home')).should \
        respond_with(SystemDiscoveryMessages.send_client_version_result(@client, 'troy@nowhere.com/home'))
      @delegate.did_receive_client_version_request_method.should be_called
    end
    
    #.........................................................................................................
    should "not respond to client version requests from jids not in configured roster" do
      @delegate.did_receive_client_version_result_method.should_not be_called
      @client.roster.has_key?('noone@nowhere.com').should be(false)
      @client.receiving(SystemDiscoveryMessages.recv_client_version_get(@client, 'noone@nowhere.com/nothing')).should not_respond
      @delegate.did_receive_client_version_request_method.should be_called
    end
    
  end

end

