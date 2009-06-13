##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestRosterManagement < Test::Unit::TestCase

  #.........................................................................................................
  def bind_resource(client)
    client.receiving(SessionMessages.recv_preauthentication_stream_features_with_plain_SASL(client)) 
    client.receiving(SessionMessages.recv_authentication_success(client)) 
    client.receiving(SessionMessages.recv_postauthentication_stream_features(client)) 
    client.receiving(SessionMessages.recv_bind_result(client))
  end

  #.........................................................................................................
  def test_roster_update(client)
    delegate = client.new_delegate
    delegate.did_receive_roster_item_method.should_not be_called
    delegate.did_receive_all_roster_items_method.should_not be_called
    yield client
    delegate.did_receive_roster_item_method.should be_called
    delegate.did_receive_all_roster_items_method.should be_called     
  end
  
  #.........................................................................................................
  should "query server for roster on succesful session start and activate configured roster items which match those returned in query result" do
  
    #### client configured with two contacts in roster
    config = {'jid' => 'test@nowhere.com', 'contacts' =>['dev@nowhere.com', 'troy@nowhere.com'], 'password' => 'nopass'}
    client = TestClient.new(config)
    delegate = client.new_delegate
    bind_resource(client)
  
    #### session starts and roster is requested
    delegate.did_start_session_method.should_not be_called
    client.receiving(SessionMessages.recv_session_result(client)).last.should respond_with(RosterMessages.send_roster_get(client)) 
    delegate.did_start_session_method.should be_called
  
    #### receive roster request and verify that roster items are activated
    delegate.did_receive_all_roster_items_method.should_not be_called     
    client.roster.values{|v| v[:status].should be(:inactive)}      
    client.receiving(RosterMessages.recv_roster_result(client, config['contacts'])).should not_respond
    client.roster.values{|v| v[:status].should be(:both)} 
    delegate.did_receive_all_roster_items_method.should be_called     
  
  end
  
  #.........................................................................................................
  should "query server for roster on succesful session start and send a subscription request to configured roster items not returned by query result" do
  
    #### client configured with two contacts in roster. 'troy@nowhere.com' will not be returned by roster initial query
    config = {'jid' => 'test@nowhere.com', 'contacts' =>['dev@nowhere.com', 'troy@nowhere.com'], 'password' => 'nopass'}
    client = TestClient.new(config)
    delegate = client.new_delegate
      
    #### session starts and roster is requested
    bind_resource(client)
    delegate.did_start_session_method.should_not be_called
    client.receiving(SessionMessages.recv_session_result(client)).last.should respond_with(RosterMessages.send_roster_get(client)) 
    delegate.did_start_session_method.should be_called
    
    #### receive roster request and verify that appropriate roster item is activated and add roster message is sent for 'troy@nowhere.com'
    test_roster_update(client) do |client|
      client.roster.values{|v| v[:status].should be(:inactive)}  
      client.receiving(RosterMessages.recv_roster_result(client, ['dev@nowhere.com'])).should \
        respond_with(RosterMessages.send_roster_set(client, 'troy@nowhere.com'))
      client.roster['dev@nowhere.com'][:status].should be(:both)      
      client.roster['troy@nowhere.com'][:status].should be(:inactive)
    end
  
    #### receive roster add ackgnowledgement and send subscription request
    delegate = client.new_delegate
    delegate.did_acknowledge_add_contact_method.should_not be_called
    client.receiving(RosterMessages.recv_roster_result_set_ack(client)).should \
      respond_with(RosterMessages.send_presence_subscribe(client, 'troy@nowhere.com'))
    delegate.did_acknowledge_add_contact_method.should be_called

    #### receive roster update with subscribe=none for newly added contact
    test_roster_update(client) do |client|
      client.receiving(RosterMessages.recv_roster_set_none(client, 'troy@nowhere.com')).should not_respond
      client.roster['troy@nowhere.com'][:status].should be(:added)      
    end

    #### receive roster update with subscription=none and ask=subscribe indicating pending susbscription request for newly added contact
    test_roster_update(client) do |client|
      client.receiving(RosterMessages.recv_roster_set_subscribe_none(client, 'troy@nowhere.com')).should not_respond
      client.roster['troy@nowhere.com'][:status].should be(:ask)      
    end
    
    #### receive roster update with subscription=to indicating that the contact's presence updates will be received 
    #### (i.e. the contact accepted the invite)
    test_roster_update(client) do |client|
      client.receiving(RosterMessages.recv_roster_set_to(client, 'troy@nowhere.com')).should not_respond
      client.roster['troy@nowhere.com'][:status].should be(:to)
    end
    
    #### receive subscribe request from contact and accept
    delegate = client.new_delegate
    delegate.did_receive_subscribe_request_method.should_not be_called
    client.receiving(RosterMessages.recv_presence_subscribe(client, 'troy@nowhere.com')).should \
      respond_with(RosterMessages.send_presence_subscribed(client, 'troy@nowhere.com'))
    delegate.did_receive_subscribe_request_method.should be_called
    
    #### receive roster update with subscription=both indicating that the contact's presence updates will be received and contact 
    #### will treceive presence updates and activate contact roster item
    test_roster_update(client) do |client|
      client.receiving(RosterMessages.recv_roster_set_both(client, 'troy@nowhere.com')).should not_respond
      client.roster['troy@nowhere.com'][:status].should be(:both)      
    end
    
  end

  # #.........................................................................................................
  # should "query server for roster on succesful session start and send an unsubscribe request to roster items returned by query result that are not in configured roster" do
  # end
  #   
  # ####......................................................................................................
  # context "a client instance" do
  # 
  #   #.........................................................................................................
  #   setup do 
  #     @client = TestClient.new
  #   end
  #   
  #   #.........................................................................................................
  #   should "accept self presence message and do nothing" do
  #   end
  # 
  #   #.........................................................................................................
  #   should "make roster item inactive when unavable presence is received" do
  #   end
  # 
  #   #.........................................................................................................
  #   should "decline subscription requests which are not in the configured roster" do
  #   end
  # 
  # end

end
