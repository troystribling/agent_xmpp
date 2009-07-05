#####-------------------------------------------------------------------------------------------------------
class Test::Unit::TestCase

  #.........................................................................................................
  def bind_resource(client)
    client.receiving(SessionMessages.recv_preauthentication_stream_features_with_plain_SASL(client)) 
    client.receiving(SessionMessages.recv_auth_success(client)) 
    client.receiving(SessionMessages.recv_postauthentication_stream_features(client)) 
    client.receiving(SessionMessages.recv_iq_result_bind(client))
  end

  #.........................................................................................................
  def test_send_roster_request(client)

    #### client configured with two contacts in roster
    delegate = client.new_delegate
    bind_resource(client)
  
    #### session starts and roster is requested
    delegate.did_start_session_method.should_not be_called
    client.receiving(SessionMessages.recv_iq_result_session(client)).should \
      respond_with(SessionMessages.send_presence_init(client), RosterMessages.send_iq_get_query_roster(client), \
                   ServiceDiscoveryMessages.send_iq_get_query_discoinfo_to_server(client)) 
    delegate.did_start_session_method.should be_called
  
  end
  
  #.........................................................................................................
  def test_init_roster(client)

    #### client configured with two contacts in roster
    test_send_roster_request(client)
    delegate = client.new_delegate
  
    #### receive roster request and verify that roster items are activated
    delegate.did_receive_all_roster_items_method.should_not be_called     
    client.roster.find_all{|r| r.status.should be(:inactive)}  
    client.receiving(RosterMessages.recv_iq_result_query_roster(client, client.config['roster'])).should not_respond
    client.roster.find_all{|r| r.status.should be(:both)}  
    delegate.did_receive_all_roster_items_method.should be_called     
  end
  
end