##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestPresenceManagement < Test::Unit::TestCase

  def first_presence
    @client.roster['troy@nowhere.com'][:resources].should be_empty
    @delegate.did_receive_presence_method.should_not be_called
    @client.receiving(PresenceMessages.recv_presence_available(@client, 'troy@nowhere.com/home')).should \
      respond_with(SystemDiscoveryMessages.send_client_version_get(@client, 'troy@nowhere.com/home'))
    @delegate.did_receive_presence_method.should be_called
    @client.roster['troy@nowhere.com'][:resources]['troy@nowhere.com/home'][:presence].should_not be_nil
  end
  
  ####------------------------------------------------------------------------------------------------------
  context "a specified client configuration" do
  
    #.........................................................................................................
    setup do
      @config = {'jid' => 'test@nowhere.com', 'contacts' =>['dev@nowhere.com', 'troy@nowhere.com'], 'password' => 'nopass'}
      @client = TestClient.new(@config)
      test_init_roster(@client, @config)
      @delegate = @client.new_delegate
    end
    
    #.........................................................................................................
    should "create presence status for resource on receipt of self presence" do
      @client.roster[@client.client.jid.bare.to_s][:resources].should be_empty
      @delegate.did_receive_presence_method.should_not be_called
      @client.receiving(PresenceMessages.recv_presence_self(@client)).should not_respond
      @delegate.did_receive_presence_method.should be_called
      @client.roster[@client.client.jid.bare.to_s][:resources][@client.client.jid.to_s][:presence].should_not be_nil
    end
    
    #.........................................................................................................
    should "on receipt of first presence message from jid, create presence status for resource and send client version request to jid for roster items with jids in configured roster" do
      first_presence
    end
      
    #.........................................................................................................
    should "update presence status for an existing resource" do
    end
     
    #.........................................................................................................
    should "maintain multiple presence status entries for a roster item with jid in configiured roster" do
    end
     
    #.........................................................................................................
    should "ignore presence messages from jids not in configured roster" do
    end
      
    #.........................................................................................................
    should "accept subscription requests from jids which are in the configured roster" do
      @delegate.did_receive_subscribe_request_method.should_not be_called
      @client.receiving(PresenceMessages.recv_presence_subscribe(@client, 'troy@nowhere.com')).should \
        respond_with(PresenceMessages.send_presence_subscribed(@client, 'troy@nowhere.com'))
      @client.receiving(PresenceMessages.recv_presence_subscribed(@client, 'troy@nowhere.com')).should not_respond
      @delegate.did_receive_subscribe_request_method.should be_called
    end
    
    #.........................................................................................................
    should "decline subscription requests from jids which are not in the configured roster" do
      @delegate.did_receive_subscribe_request_method.should_not be_called
      @client.receiving(PresenceMessages.recv_presence_subscribe(@client, 'noone@nowhere.com')).should \
        respond_with(PresenceMessages.send_presence_unsubscribed(@client, 'noone@nowhere.com'))
      @delegate.did_receive_subscribe_request_method.should be_called
    end
    
  end

end

