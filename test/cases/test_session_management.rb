##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestSessionManagement < Test::Unit::TestCase

  #.........................................................................................................
  def setup
    @client = TestClient.new
    AgentXmpp::Xmpp::IdGenerator.set_gen_id
    @delegate = @client.new_delegate
  end
  
  #.........................................................................................................
  should "authenticate with PLAIN SASL authentication when stream features includes PLAIN authentication" do
  
    #### connect to server
    @client.client.pipe.connection_completed.should \
      respond_with(SessionMessages.send_supported_xml_version(@client), SessionMessages.send_stream(@client))
  
    #### receive pre authentication stream feautues and mechanisms and authenticate
    @delegate.did_authenticate_method.should_not be_called
    @delegate.did_receive_preauthenticate_features_method.should_not be_called
    @client.receiving(SessionMessages.recv_preauthentication_stream_features_with_plain_SASL(@client)).should \
      respond_with(SessionMessages.send_auth_plain(@client)) 
    @client.receiving(SessionMessages.recv_auth_success(@client)).should respond_with(SessionMessages.send_stream(@client)) 
    @delegate.did_receive_preauthenticate_features_method.should be_called
    @delegate.did_authenticate_method.should be_called
  
    #### bind resource
    @delegate.did_bind_method.should_not be_called
    @delegate.did_receive_postauthenticate_features_method.should_not be_called
    @client.receiving(SessionMessages.recv_postauthentication_stream_features(@client)).should respond_with(SessionMessages.send_iq_set_bind(@client)) 
    @client.receiving(SessionMessages.recv_iq_result_bind(@client)).should respond_with(SessionMessages.send_iq_set_session(@client)) 
    @delegate.did_receive_postauthenticate_features_method.should be_called
    @delegate.did_bind_method.should be_called
  
    #### start session and request roster
    @delegate.did_start_session_method.should_not be_called
    @client.receiving(SessionMessages.recv_iq_result_session(@client)).should \
      respond_with(SessionMessages.send_presence_init(@client), RosterMessages.send_iq_get_query_roster(@client)) 
    @delegate.did_start_session_method.should be_called
  
  end
  
  #.........................................................................................................
  should "raise exception when stream features do not include PLAIN authentication" do
  
    #### connect to server
    @client.client.pipe.connection_completed
  
    #### receive pre authentication stream feautues which do not include plain authentication
    lambda{@client.receiving(SessionMessages.recv_preauthentication_stream_features_without_plain_SASL(@client))}.should \
      raise_error(AgentXmpp::AgentXmppError) 
  end
  
  #.........................................................................................................
  should "raise exception when authentication fails" do
    
    #### connect to server
    @client.client.pipe.connection_completed
  
    #### receive pre authentication stream feautues and mechanisms and authenticate
    @client.receiving(SessionMessages.recv_preauthentication_stream_features_with_plain_SASL(@client)).should \
      respond_with(SessionMessages.send_auth_plain(@client)) 
    lambda{@client.receiving(SessionMessages.recv_auth_failure(@client))}.should raise_error(AgentXmpp::AgentXmppError) 
    
  end
  
  #.........................................................................................................
  should "raise exception when bind fails" do
  
    #### connect to server
    @client.client.pipe.connection_completed
  
    #### receive pre authentication stream feautues and mechanisms and authenticate
    @delegate.did_authenticate_method.should_not be_called
    @delegate.did_receive_preauthenticate_features_method.should_not be_called
    @client.receiving(SessionMessages.recv_preauthentication_stream_features_with_plain_SASL(@client)).should \
      respond_with(SessionMessages.send_auth_plain(@client)) 
    @client.receiving(SessionMessages.recv_auth_success(@client)).should respond_with(SessionMessages.send_stream(@client)) 
    @delegate.did_receive_preauthenticate_features_method.should be_called
    @delegate.did_authenticate_method.should be_called
  
    #### bind resource and receive error
    @client.receiving(SessionMessages.recv_postauthentication_stream_features(@client)).should respond_with(SessionMessages.send_iq_set_bind(@client)) 
    lambda{@client.receiving(SessionMessages.recv_error_bind(@client))}.should raise_error(AgentXmpp::AgentXmppError) 
  
  end
  
  #.........................................................................................................
  should "raise exception when session start fails" do
  
    #### connect to server
    @client.client.pipe.connection_completed
  
    #### receive pre authentication stream feautues and mechanisms and authenticate
    @delegate.did_authenticate_method.should_not be_called
    @delegate.did_receive_preauthenticate_features_method.should_not be_called
    @client.receiving(SessionMessages.recv_preauthentication_stream_features_with_plain_SASL(@client)).should \
      respond_with(SessionMessages.send_auth_plain(@client)) 
    @client.receiving(SessionMessages.recv_auth_success(@client)).should respond_with(SessionMessages.send_stream(@client)) 
    @delegate.did_receive_preauthenticate_features_method.should be_called
    @delegate.did_authenticate_method.should be_called
  
    #### bind resource
    @delegate.did_receive_postauthenticate_features_method.should_not be_called
    @delegate.did_bind_method.should_not be_called
    @client.receiving(SessionMessages.recv_postauthentication_stream_features(@client)).should respond_with(SessionMessages.send_iq_set_bind(@client)) 
    @client.receiving(SessionMessages.recv_iq_result_bind(@client)).should respond_with(SessionMessages.send_iq_set_session(@client)) 
    @delegate.did_receive_postauthenticate_features_method.should be_called
    @delegate.did_bind_method.should be_called
  
    #### start session and request roster
    lambda{@client.receiving(SessionMessages.recv_error_session(@client))}.should raise_error(AgentXmpp::AgentXmppError) 
  
  end
  
end
