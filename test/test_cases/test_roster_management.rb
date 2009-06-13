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

  # #.........................................................................................................
  # should "query server for roster on succesful session start and activate configured roster items which match those returned in query result" do
  # 
  #   #### client configured with two contacts in roster
  #   config = {'jid' => 'test@nowhere.com', 'contacts' =>['dev@nowhere.com', 'troy@nowhere.com'], 'password' => 'nopass'}
  #   client = TestClient.new(config)
  #   bind_resource(client)
  # 
  #   #### session starts and roster is requested
  #   client.receiving(SessionMessages.recv_session_result(client)).last.should respond_with(RosterMessages.send_roster_get(client)) 
  #   TestDelegate.did_start_session_method.should be_called
  # 
  #   #### receive roster request and verify that roster items are activated
  #   client.roster.values{|v| v[:activated].should be(false)}      
  #   client.receiving(RosterMessages.recv_roster_result(client, config['contacts'])).should not_respond
  #   client.roster.values{|v| v[:activated].should be(true)} 
  #   TestDelegate.did_receive_all_roster_items_method.should be_called     
  # 
  # end
  
  #.........................................................................................................
  should "query server for roster on succesful session start and send a subscription request to configured roster items not returned by query result" do
  
    #### client configured with two contacts in roster
    config = {'jid' => 'test@nowhere.com', 'contacts' =>['dev@nowhere.com', 'troy@nowhere.com'], 'password' => 'nopass'}
    client = TestClient.new(config)
    bind_resource(client)
      
    #### session starts and roster is requested
    client.receiving(SessionMessages.recv_session_result(client)).last.should respond_with(RosterMessages.send_roster_get(client)) 
    TestDelegate.did_start_session_method.should be_called
    
    #### receive roster request and verify that appropriate roster item is activated and add roster message is sent
    client.roster.values{|v| v[:activated].should be(false)}  
    client.receiving(RosterMessages.recv_roster_result(client, ['dev@nowhere.com'])).should \
      respond_with(RosterMessages.send_roster_set(client, 'troy@nowhere.com'))
    TestDelegate.did_receive_roster_item_method.should be_called
    client.roster['dev@nowhere.com'][:activated].should be(true)      
    client.roster['troy@nowhere.com'][:activated].should be(false)      
    TestDelegate.did_receive_all_roster_items_method.should be_called     
  
    #### receive roster add ackgnowledgement and send subscription request
    client.receiving(RosterMessages.recv_roster_result_set_ack(client)).should respond_with(RosterMessages.send_presence_subscribe(client, 'troy@nowhere.com'))
    TestDelegate.did_acknowledge_add_contact_method.should be_called

    #### receive roster update with subscribe=none for newly added contact
    client.receiving(RosterMessages.recv_roster_set_none(client, 'troy@nowhere.com')).should not_respond
    client.roster['troy@nowhere.com'][:activated].should be(false)      

    #### receive roster update with subscription=none and ask=subscribe indicating pending susbscription request for newly added contact
p client.receiving(RosterMessages.recv_roster_set_subscribe_none(client, 'troy@nowhere.com'))    
    client.receiving(RosterMessages.recv_roster_set_subscribe_none(client, 'troy@nowhere.com')).should not_respond
    client.roster['troy@nowhere.com'][:activated].should be(false)      

    #### receive roster update with subscription=to indicating that the contact's presence updates will be received 
    #### (i.e. the contact accepted the invite)
    client.receiving(RosterMessages.recv_roster_set_subscribe_to(client, 'troy@nowhere.com')).should not_respond
    client.roster['troy@nowhere.com'][:activated].should be(false)      

    #### receive subscribe request from contact and accept
    client.receiving(RosterMessages.recv_presence_subscribe(client, 'troy@nowhere.com')).should \
      respond_with(RosterMessages.send_presence_subscribed(client, 'troy@nowhere.com'))
    client.roster['troy@nowhere.com'][:activated].should be(false)      

    #### receive roster update with subscription=both indicating that the contact's presence updates will be received and contact 
    #### will treceive presence updates also activate contact roster item
    client.receiving(RosterMessages.recv_roster_set_subscribe_to(client, 'troy@nowhere.com')).should not_respond
    client.roster['troy@nowhere.com'][:activated].should be(true)      
    
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
