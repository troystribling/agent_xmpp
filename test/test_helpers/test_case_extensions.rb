#####-------------------------------------------------------------------------------------------------------
class Test::Unit::TestCase

  #.........................................................................................................
  def bind_resource(client)
    client.receiving(SessionMessages.recv_preauthentication_stream_features_with_plain_SASL(client)) 
    client.receiving(SessionMessages.recv_authentication_success(client)) 
    client.receiving(SessionMessages.recv_postauthentication_stream_features(client)) 
    client.receiving(SessionMessages.recv_bind_result(client))
  end

  #.........................................................................................................
  def test_send_roster_request(client, config)

    #### client configured with two contacts in roster
    delegate = client.new_delegate
    bind_resource(client)
  
    #### session starts and roster is requested
    delegate.did_start_session_method.should_not be_called
    client.receiving(SessionMessages.recv_session_result(client)).last.should respond_with(RosterMessages.send_roster_get(client)) 
    delegate.did_start_session_method.should be_called
  
  end
  
  #.........................................................................................................
  def test_init_roster(client, config)

    #### client configured with two contacts in roster
    test_send_roster_request(client, config)
    delegate = client.new_delegate
  
    #### receive roster request and verify that roster items are activated
    delegate.did_receive_all_roster_items_method.should_not be_called     
    client.roster.values{|v| v[:status].should be(:inactive)}      
    client.receiving(RosterMessages.recv_roster_result(client, config['contacts'])).should not_respond
    client.roster.values{|v| v[:status].should be(:both)} 
    delegate.did_receive_all_roster_items_method.should be_called     
  end
  
end
