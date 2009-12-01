##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestRosterManagement < Test::Unit::TestCase

  #.........................................................................................................
  def setup
    @troy = AgentXmpp::Xmpp::Jid.new('troy@nowhere.com')
    @dev = AgentXmpp::Xmpp::Jid.new('dev@nowhere.com')
  end
    
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
  
    config = {'jid' => 'test@nowhere.com', 'roster' =>[@dev.bare.to_s, @troy.bare.to_s], 'password' => 'nopass'}
    client = TestClient.new(config)
    test_init_roster(client)
    
  end
  
  #.........................................................................................................
  should "query server for roster on succesful session start and send a subscription request to configured roster items not returned by query result" do
  
    #### client configured with two contacts in roster. 'troy@nowhere.com' will not be returned by roster initial query
    config = {'jid' => 'test@nowhere.com', 'roster' =>[@dev.bare.to_s, @troy.bare.to_s], 'password' => 'nopass'}
    client = TestClient.new(config)
    test_send_roster_request(client)
    delegate = client.new_delegate
    
    #### receive roster request and verify that appropriate roster item is activated and add roster message is sent for 'troy@nowhere.com'
    test_receive_roster_item(client) do |client|
      AgentXmpp::Roster.find_all{|r| r[:status].should be(:inactive)}  
      client.receiving(RosterMessages.recv_iq_result_query_roster(client, [@dev.bare.to_s])).should \
        respond_with(RosterMessages.send_iq_set_query_roster(client, @troy.bare.to_s))
      AgentXmpp::Contact.find_by_jid(@dev)[:status].should be(:both)      
      AgentXmpp::Contact.find_by_jid(@troy)[:status].should be(:inactive)
    end
  
    ### receive roster add ackgnowledgement and send subscription request
    delegate = client.new_delegate
    delegate.did_acknowledge_add_roster_item_method.should_not be_called
    client.receiving(RosterMessages.recv_iq_result_query_roster_ack(client)).should \
      respond_with(PresenceMessages.send_presence_subscribe(client, @troy.bare.to_s))
    delegate.did_acknowledge_add_roster_item_method.should be_called
  
    #### receive roster update with subscribe=none for newly added contact
    test_receive_roster_item(client) do |client|
      client.receiving(RosterMessages.recv_iq_set_query_roster_none(client, @troy.bare.to_s)).should not_respond
      AgentXmpp::Contact.find_by_jid(@troy)[:status].should be(:added)      
    end
  
    #### receive roster update with subscription=none and ask=subscribe indicating pending susbscription request for newly added contact
    test_receive_roster_item(client) do |client|
      client.receiving(RosterMessages.recv_iq_set_query_roster_none_subscribe(client, @troy.bare.to_s)).should not_respond
      AgentXmpp::Contact.find_by_jid(@troy)[:status].should be(:ask)      
    end
    
    #### receive roster update with subscription=to indicating that the contact's presence updates will be received 
    #### (i.e. the contact accepted the invite)
    test_receive_roster_item(client) do |client|
      client.receiving(RosterMessages.recv_iq_set_query_roster_to(client, @troy.bare.to_s)).should not_respond
      AgentXmpp::Contact.find_by_jid(@troy)[:status].should be(:to)
    end
    
    #### receive subscribe request from contact and accept
    delegate = client.new_delegate
    delegate.did_receive_presence_subscribe_method.should_not be_called
    client.receiving(PresenceMessages.recv_presence_subscribe(client, @troy.bare.to_s)).should \
      respond_with(PresenceMessages.send_presence_subscribed(client, @troy.bare.to_s))
    delegate.did_receive_presence_subscribe_method.should be_called
    
    #### receive roster update with subscription=both indicating that the contact's presence updates will be received and contact 
    #### will treceive presence updates and activate contact roster item
    test_receive_roster_item(client) do |client|
      client.receiving(RosterMessages.recv_iq_set_query_roster_both(client, @troy.bare.to_s)).should not_respond
      AgentXmpp::Contact.find_by_jid(@troy)[:status].should be(:both)      
    end
    
  end
  
  #.........................................................................................................
  should "query server for roster on succesful session start and send an unsubscribe request to roster items returned by query result that are not in the configuration roster" do
  
    #### client configured with one contact in roster. 'troy@nowhere.com' will be returned by roster initial query
    config = {'jid' => 'test@nowhere.com', 'roster' =>[@dev.bare.to_s], 'password' => 'nopass'}
    client = TestClient.new(config)
    test_send_roster_request(client)
    delegate = client.new_delegate
    
    #### receive roster request and verify that appropriate roster item is activated and remove roster message is sent for 'troy@nowhere.com'
    test_receive_roster_item(client) do |client|
      AgentXmpp::Roster.find_all{|r| r[:status].should be(:inactive)}  
      client.receiving(RosterMessages.recv_iq_result_query_roster(client, [@dev.bare.to_s, @troy.bare.to_s])).should \
        respond_with(RosterMessages.send_iq_set_query_roster_remove(client, @troy.bare.to_s))
      AgentXmpp::Contact.find_by_jid(@dev)[:status].should be(:both)      
    end
  
    #### receive roster remove ackgnowledgement
    delegate = client.new_delegate
    delegate.did_acknowledge_remove_roster_item_method.should_not be_called
    client.receiving(RosterMessages.recv_iq_result_query_roster_ack(client)).should not_respond
    delegate.did_acknowledge_remove_roster_item_method.should be_called
  
    #### recieve roster item remove
    delegate.did_remove_roster_item_method.should_not be_called
    delegate.did_receive_all_roster_items_method.should_not be_called
    client.receiving(RosterMessages.recv_iq_set_query_roster_remove(client, @troy.bare.to_s)).should not_respond
    AgentXmpp::Contact.has_jid?(@troy).should be(false) 
    delegate.did_remove_roster_item_method.should be_called
    delegate.did_receive_all_roster_items_method.should be_called
  
  end
    
  #.........................................................................................................
  should "remove roster item if a roster add message is received for a roster item not in the configuration roster" do
  
    config = {'jid' => 'test@nowhere.com', 'roster' =>[@dev.bare.to_s], 'password' => 'nopass'}
    client = TestClient.new(config)
    test_init_roster(client)
  
    #### receive roster request and verify that appropriate roster item is not configured and send remove roster message to 'troy@nowhere.com'
    test_receive_roster_item(client) do |client|
      AgentXmpp::Roster.find_all{|r| r[:status].should be(:inactive)}  
      client.receiving(RosterMessages.recv_iq_set_query_roster_none_subscribe(client, [@troy.bare.to_s])).should \
        respond_with(RosterMessages.send_iq_set_query_roster_remove(client, @troy.bare.to_s))
      AgentXmpp::Contact.has_jid?(@troy).should be(false) 
    end
  
    #### receive roster remove ackgnowledgement
    delegate = client.new_delegate
    delegate.did_acknowledge_remove_roster_item_method.should_not be_called
    client.receiving(RosterMessages.recv_iq_result_query_roster_ack(client)).should not_respond
    delegate.did_acknowledge_remove_roster_item_method.should be_called
  
  end
    
  #.........................................................................................................
  should "query server for roster on succesful session start and throw an exeception if there is an error retrieving roster" do
  
    #### client configured with two contacts in roster
    config = {'jid' => 'test@nowhere.com', 'roster' =>[@dev.bare.to_s], 'password' => 'nopass'}
    client = TestClient.new(config)
    test_send_roster_request(client)
    delegate = client.new_delegate
  
    #### receive roster request and verify that roster items are activated
    lambda{client.receiving(RosterMessages.recv_error_query_roster_add(client))}.should raise_error(AgentXmpp::AgentXmppError) 
  
  end
    
  #.........................................................................................................
  should "not respond to errors received in response to a remove roster query" do
  
    config = {'jid' => 'test@nowhere.com', 'roster' =>[@dev.bare.to_s], 'password' => 'nopass'}
    client = TestClient.new(config)
    test_init_roster(client)
  
    #### receive roster request and verify that appropriate roster item is not configured and send remove roster message to 'troy@nowhere.com'
    test_receive_roster_item(client) do |client|
      AgentXmpp::Roster.find_all{|r| r[:status].should be(:inactive)}  
      client.receiving(RosterMessages.recv_iq_set_query_roster_none_subscribe(client, [@troy.bare.to_s])).should \
        respond_with(RosterMessages.send_iq_set_query_roster_remove(client, @troy.bare.to_s))
      AgentXmpp::Contact.has_jid?(@troy).should be(false) 
    end
  
    #### receive roster remove ackgnowledgement
    delegate = client.new_delegate
    delegate.did_receive_remove_roster_item_error_method.should_not be_called
    client.receiving(RosterMessages.recv_error_query_roster_remove(client)).should not_respond
    AgentXmpp::Contact.has_jid?(@troy).should be(false) 
    delegate.did_receive_remove_roster_item_error_method.should be_called
    
  end
  
  #.........................................................................................................
  should "not respond to errors received in response to an add roster query but should remove roster item from configured list" do
  
    #### client configured with two contacts in roster. 'troy@nowhere.com' will not be returned by roster initial query
    config = {'jid' => 'test@nowhere.com', 'roster' =>[@dev.bare.to_s, @troy.bare.to_s], 'password' => 'nopass'}
    client = TestClient.new(config)
    test_send_roster_request(client)
    delegate = client.new_delegate
    
    #### receive roster request and verify that appropriate roster item is activated and add roster message is sent for 'troy@nowhere.com'
    test_receive_roster_item(client) do |client|
      AgentXmpp::Roster.find_all{|r| r[:status].should be(:inactive)}  
      client.receiving(RosterMessages.recv_iq_result_query_roster(client, [@dev.bare.to_s])).should \
        respond_with(RosterMessages.send_iq_set_query_roster(client, @troy.bare.to_s))
      AgentXmpp::Contact.find_by_jid(@dev)[:status].should be(:both)      
      AgentXmpp::Contact.find_by_jid(@troy)[:status].should be(:inactive)
    end
  
    ### receive roster add ackgnowledgement and send subscription request
    delegate = client.new_delegate
    delegate.did_receive_add_roster_item_error_method.should_not be_called
    client.receiving(RosterMessages.recv_error_query_roster_remove(client)).should not_respond
    delegate.did_receive_add_roster_item_error_method.should be_called
    AgentXmpp::Contact.has_jid?(@troy).should be(false) 
    
  end
  
end
