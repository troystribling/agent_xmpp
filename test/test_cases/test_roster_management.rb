##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestRosterManagement < Test::Unit::TestCase

   #.........................................................................................................
  def test_receive_roster_item(client)
    delegate = client.new_delegate
    delegate.did_receive_roster_item_method.should_not be_called
    delegate.did_receive_all_roster_items_method.should_not be_called
    yield client
    delegate.did_receive_roster_item_method.should be_called
    delegate.did_receive_all_roster_items_method.should be_called     
  end
  
  ####------------------------------------------------------------------------------------------------------
  #.........................................................................................................
  should "query server for roster on succesful session start and activate configured roster items which match those returned in query result" do
  
    config = {'jid' => 'test@nowhere.com', 'contacts' =>['dev@nowhere.com', 'troy@nowhere.com'], 'password' => 'nopass'}
    client = TestClient.new(config)
    test_init_roster(client, config)
    
  end
  
  #.........................................................................................................
  should "query server for roster on succesful session start and send a subscription request to configured roster items not returned by query result" do
  
    #### client configured with two contacts in roster. 'troy@nowhere.com' will not be returned by roster initial query
    config = {'jid' => 'test@nowhere.com', 'contacts' =>['dev@nowhere.com', 'troy@nowhere.com'], 'password' => 'nopass'}
    client = TestClient.new(config)
    test_send_roster_request(client, config)
    delegate = client.new_delegate
    
    #### receive roster request and verify that appropriate roster item is activated and add roster message is sent for 'troy@nowhere.com'
    test_receive_roster_item(client) do |client|
      client.roster.values{|v| v[:status].should be(:inactive)}  
      client.receiving(RosterMessages.recv_roster_result(client, ['dev@nowhere.com'])).should \
        respond_with(RosterMessages.send_roster_set(client, 'troy@nowhere.com'))
      client.roster['dev@nowhere.com'][:status].should be(:both)      
      client.roster['troy@nowhere.com'][:status].should be(:inactive)
    end
  
    ### receive roster add ackgnowledgement and send subscription request
    delegate = client.new_delegate
    delegate.did_acknowledge_add_roster_item_method.should_not be_called
    client.receiving(RosterMessages.recv_roster_result_set_ack(client)).should \
      respond_with(PresenceMessages.send_presence_subscribe(client, 'troy@nowhere.com'))
    delegate.did_acknowledge_add_roster_item_method.should be_called
  
    #### receive roster update with subscribe=none for newly added contact
    test_receive_roster_item(client) do |client|
      client.receiving(RosterMessages.recv_roster_set_none(client, 'troy@nowhere.com')).should not_respond
      client.roster['troy@nowhere.com'][:status].should be(:added)      
    end
  
    #### receive roster update with subscription=none and ask=subscribe indicating pending susbscription request for newly added contact
    test_receive_roster_item(client) do |client|
      client.receiving(RosterMessages.recv_roster_set_subscribe_none(client, 'troy@nowhere.com')).should not_respond
      client.roster['troy@nowhere.com'][:status].should be(:ask)      
    end
    
    #### receive roster update with subscription=to indicating that the contact's presence updates will be received 
    #### (i.e. the contact accepted the invite)
    test_receive_roster_item(client) do |client|
      client.receiving(RosterMessages.recv_roster_set_to(client, 'troy@nowhere.com')).should not_respond
      client.roster['troy@nowhere.com'][:status].should be(:to)
    end
    
    #### receive subscribe request from contact and accept
    delegate = client.new_delegate
    delegate.did_receive_subscribe_request_method.should_not be_called
    client.receiving(PresenceMessages.recv_presence_subscribe(client, 'troy@nowhere.com')).should \
      respond_with(PresenceMessages.send_presence_subscribed(client, 'troy@nowhere.com'))
    delegate.did_receive_subscribe_request_method.should be_called
    
    #### receive roster update with subscription=both indicating that the contact's presence updates will be received and contact 
    #### will treceive presence updates and activate contact roster item
    test_receive_roster_item(client) do |client|
      client.receiving(RosterMessages.recv_roster_set_both(client, 'troy@nowhere.com')).should not_respond
      client.roster['troy@nowhere.com'][:status].should be(:both)      
    end
    
  end
  
  #.........................................................................................................
  should "query server for roster on succesful session start and send an unsubscribe request to roster items returned by query result that are not in the configuration roster" do
  
    #### client configured with one contact in roster. 'troy@nowhere.com' will be returned by roster initial query
    config = {'jid' => 'test@nowhere.com', 'contacts' =>['dev@nowhere.com'], 'password' => 'nopass'}
    client = TestClient.new(config)
    test_send_roster_request(client, config)
    delegate = client.new_delegate
    
    #### receive roster request and verify that appropriate roster item is activated and remove roster message is sent for 'troy@nowhere.com'
    test_receive_roster_item(client) do |client|
      client.roster.values{|v| v[:status].should be(:inactive)}  
      client.receiving(RosterMessages.recv_roster_result(client, ['dev@nowhere.com', 'troy@nowhere.com'])).should \
        respond_with(RosterMessages.send_roster_set_remove(client, 'troy@nowhere.com'))
      client.roster['dev@nowhere.com'][:status].should be(:both)      
    end
  
    #### receive roster remove ackgnowledgement
    delegate = client.new_delegate
    delegate.did_acknowledge_remove_roster_item_method.should_not be_called
    client.receiving(RosterMessages.recv_roster_result_set_ack(client)).should not_respond
    delegate.did_acknowledge_remove_roster_item_method.should be_called
  
    #### recieve roster item remove
    delegate.did_remove_roster_item_method.should_not be_called
    delegate.did_receive_all_roster_items_method.should_not be_called
    client.receiving(RosterMessages.recv_roster_set_remove(client, 'troy@nowhere.com')).should not_respond
    client.roster.has_key?('troy@nowhere.com').should be(false) 
    delegate.did_remove_roster_item_method.should be_called
    delegate.did_receive_all_roster_items_method.should be_called
  
  end
    
  #.........................................................................................................
  should "remove roster item if a roster add message is received for a roster item not in the configuration roster" do
  
    config = {'jid' => 'test@nowhere.com', 'contacts' =>['dev@nowhere.com'], 'password' => 'nopass'}
    client = TestClient.new(config)
    test_init_roster(client, config)
  
    #### receive roster request and verify that appropriate roster item is not configured and send remove roster message to 'troy@nowhere.com'
    test_receive_roster_item(client) do |client|
      client.roster.values{|v| v[:status].should be(:inactive)}  
      client.receiving(RosterMessages.recv_roster_set_subscribe_none(client, ['troy@nowhere.com'])).should \
        respond_with(RosterMessages.send_roster_set_remove(client, 'troy@nowhere.com'))
      client.roster.has_key?('troy@nowhere.com').should be(false) 
    end
  
    #### receive roster remove ackgnowledgement
    delegate = client.new_delegate
    delegate.did_acknowledge_remove_roster_item_method.should_not be_called
    client.receiving(RosterMessages.recv_roster_result_set_ack(client)).should not_respond
    delegate.did_acknowledge_remove_roster_item_method.should be_called
  
  end
    
  #.........................................................................................................
  should "query server for roster on succesful session start and throw an exeception if there is an error retrieving roster" do
  
    #### client configured with two contacts in roster
    config = {'jid' => 'test@nowhere.com', 'contacts' =>['dev@nowhere.com'], 'password' => 'nopass'}
    client = TestClient.new(config)
    test_send_roster_request(client, config)
    delegate = client.new_delegate
  
    #### receive roster request and verify that roster items are activated
    lambda{client.receiving(RosterMessages.recv_roster_error(client))}.should raise_error(AgentXmpp::AgentXmppError) 
  
  end
    
  #.........................................................................................................
  should "not respond to errors received in response to a remove roster query" do
  
    config = {'jid' => 'test@nowhere.com', 'contacts' =>['dev@nowhere.com'], 'password' => 'nopass'}
    client = TestClient.new(config)
    test_init_roster(client, config)
  
    #### receive roster request and verify that appropriate roster item is not configured and send remove roster message to 'troy@nowhere.com'
    test_receive_roster_item(client) do |client|
      client.roster.values{|v| v[:status].should be(:inactive)}  
      client.receiving(RosterMessages.recv_roster_set_subscribe_none(client, ['troy@nowhere.com'])).should \
        respond_with(RosterMessages.send_roster_set_remove(client, 'troy@nowhere.com'))
      client.roster.has_key?('troy@nowhere.com').should be(false) 
    end
  
    #### receive roster remove ackgnowledgement
    delegate = client.new_delegate
    delegate.did_receive_remove_roster_item_error_method.should_not be_called
    client.receiving(RosterMessages.recv_roster_result_set_error(client)).should not_respond
    client.roster.has_key?('troy@nowhere.com').should be(false) 
    delegate.did_receive_remove_roster_item_error_method.should be_called
    
  end
  
  #.........................................................................................................
  should "not respond to errors received in response to an add roster query but should remove roster item from configured list" do
  
    #### client configured with two contacts in roster. 'troy@nowhere.com' will not be returned by roster initial query
    config = {'jid' => 'test@nowhere.com', 'contacts' =>['dev@nowhere.com', 'troy@nowhere.com'], 'password' => 'nopass'}
    client = TestClient.new(config)
    test_send_roster_request(client, config)
    delegate = client.new_delegate
    
    #### receive roster request and verify that appropriate roster item is activated and add roster message is sent for 'troy@nowhere.com'
    test_receive_roster_item(client) do |client|
      client.roster.values{|v| v[:status].should be(:inactive)}  
      client.receiving(RosterMessages.recv_roster_result(client, ['dev@nowhere.com'])).should \
        respond_with(RosterMessages.send_roster_set(client, 'troy@nowhere.com'))
      client.roster['dev@nowhere.com'][:status].should be(:both)      
      client.roster['troy@nowhere.com'][:status].should be(:inactive)
    end
  
    ### receive roster add ackgnowledgement and send subscription request
    delegate = client.new_delegate
    delegate.did_receive_add_roster_item_error_method.should_not be_called
    client.receiving(RosterMessages.recv_roster_result_set_error(client)).should not_respond
    delegate.did_receive_add_roster_item_error_method.should be_called
    client.roster.has_key?('troy@nowhere.com').should be(false) 
    
  end
  
end
