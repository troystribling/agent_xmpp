##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestPresenceManagement < Test::Unit::TestCase

  #.........................................................................................................
  def setup
    @config = {'jid' => 'test@nowhere.com', 'contacts' =>['dev@nowhere.com', 'troy@nowhere.com'], 'password' => 'nopass'}
    @client = TestClient.new(@config)
    test_init_roster(@client, @config)
    @delegate = @client.new_delegate
  end
    
  ####------------------------------------------------------------------------------------------------------
  context "on receipt of first presence message from jid in configured roster" do
  
    setup do
      @client.roster['troy@nowhere.com'][:resources].should be_empty
      @delegate.did_receive_presence_method.should_not be_called
      @client.receiving(PresenceMessages.recv_presence_available(@client, 'troy@nowhere.com/home')).should \
        respond_with(SystemDiscoveryMessages.send_client_version_get(@client, 'troy@nowhere.com/home'))
      @delegate.did_receive_presence_method.should be_called
      @client.roster['troy@nowhere.com'][:resources]['troy@nowhere.com/home'][:presence].should_not be_nil
    end
  
    #.........................................................................................................
    should "create presence status entry in roster item record for resource and send client version request to jid" do
    end
      
    #.........................................................................................................
    should "update roster item resource presence status on receiving subsequent presence messages" do
      @delegate = @client.new_delegate
      @delegate.did_receive_presence_method.should_not be_called
      @client.roster['troy@nowhere.com'][:resources]['troy@nowhere.com/home'][:presence].type.should be_nil # nil presence type=available
      @client.receiving(PresenceMessages.recv_presence_unavailable(@client, 'troy@nowhere.com/home')).should not_respond
      @delegate.did_receive_presence_method.should be_called
      @client.roster['troy@nowhere.com'][:resources]['troy@nowhere.com/home'][:presence].type.should be(:unavailable)   
    end
     
    #.........................................................................................................
    should "maintain multiple presence status entries for multiple resources for a roster item" do
      @delegate = @client.new_delegate
      @delegate.did_receive_presence_method.should_not be_called
      @client.roster['troy@nowhere.com'][:resources]['troy@nowhere.com/work'].should be_nil
      @client.receiving(PresenceMessages.recv_presence_unavailable(@client, 'troy@nowhere.com/work')).should not_respond
      @delegate.did_receive_presence_method.should be_called
      @client.roster['troy@nowhere.com'][:resources]['troy@nowhere.com/work'][:presence].should_not be_nil  
      @client.roster['troy@nowhere.com'][:resources]['troy@nowhere.com/home'][:presence].should_not be_nil  
    end
  
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
  should "ignore presence messages from jids not in configured roster" do
    @client.roster.has_key?('noone@nowhere.com').should be(false)
    @delegate.did_receive_presence_method.should_not be_called
    @client.receiving(PresenceMessages.recv_presence_available(@client, 'noone@nowhere.com/here')).should not_respond
    @delegate.did_receive_presence_method.should be_called
    @client.roster.has_key?('noone@nowhere.com').should be(false)
  end
    
  #.........................................................................................................
  should "accept subscription requests from jids which are in the configured roster" do
    @client.roster.has_key?('troy@nowhere.com').should be(true)
    @delegate.did_receive_presence_subscribe_method.should_not be_called
    @delegate.did_receive_presence_subscribed_method.should_not be_called
    @client.receiving(PresenceMessages.recv_presence_subscribe(@client, 'troy@nowhere.com')).should \
      respond_with(PresenceMessages.send_presence_subscribed(@client, 'troy@nowhere.com'))
    @client.receiving(PresenceMessages.recv_presence_subscribed(@client, 'troy@nowhere.com')).should not_respond
    @delegate.did_receive_presence_subscribe_method.should be_called
    @delegate.did_receive_presence_subscribed_method.should be_called
    @client.roster.has_key?('troy@nowhere.com').should be(true)
  end
  
  #.........................................................................................................
  should "remove roster item with jid from configured roster when an unsubscribe resquest is recieved" do
    @client.roster.has_key?('troy@nowhere.com').should be(true)
    @delegate.did_receive_presence_unsubscribed_method.should_not be_called
    @client.receiving(PresenceMessages.recv_presence_unsubscribed(@client, 'troy@nowhere.com')).should \
      respond_with(RosterMessages.send_roster_set_remove(@client, 'troy@nowhere.com'))
    @client.receiving(RosterMessages.recv_roster_result_set_ack(@client)).should not_respond
    @delegate.did_receive_presence_unsubscribed_method.should be_called
    @client.roster.has_key?('troy@nowhere.com').should be(false)
  end
    
  #.........................................................................................................
  should "do nothing when an unsubscribe resquest is recieved from a jid not in the configured roster" do
    @client.roster.has_key?('you@nowhere.com').should be(false)
    @delegate.did_receive_presence_unsubscribed_method.should_not be_called
    @client.receiving(PresenceMessages.recv_presence_unsubscribed(@client, 'you@nowhere.com')).should not_respond
    @delegate.did_receive_presence_unsubscribed_method.should be_called
    @client.roster.has_key?('you@nowhere.com').should be(false)
  end
    
  #.........................................................................................................
  should "decline subscription requests from jids which are not in the configured roster" do
    @client.roster.has_key?('noone@nowhere.com').should be(false)
    @delegate.did_receive_presence_subscribe_method.should_not be_called
    @client.receiving(PresenceMessages.recv_presence_subscribe(@client, 'noone@nowhere.com')).should \
      respond_with(PresenceMessages.send_presence_unsubscribed(@client, 'noone@nowhere.com'))
    @delegate.did_receive_presence_subscribe_method.should be_called
    @client.roster.has_key?('noone@nowhere.com').should be(false)
  end
  
end

