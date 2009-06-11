##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestSessionManagement < Test::Unit::TestCase

  #.........................................................................................................
  def setup
    @client = TestClient.new
  end
  
  #.........................................................................................................
  should "authenticate with PLAIN SASL authentication when stream features includes PLAIN authentication" do
  
    #### connect to server. this actually happens when client is connected here callbacks and message support are verified 
    TestDelegate.did_connect_method.should be_called
    connection_init_msgs = @client.client.connection.init_connection
    connection_init_msgs.first.should be(SessionMessages.send_supported_xml_version(@client))
    connection_init_msgs.last.should be(SessionMessages.send_stream(@client))
  
    #### receive pre authentication stream feautues and mechanisms and authenticate
    @client.receiving(SessionMessages.recv_preauthentication_stream_features_with_plain_SASL(@client)).should 
      respond_with(SessionMessages.send_plain_authentication(@client)) 
    @client.receiving(SessionMessages.recv_authentication_success(@client)).should respond_with(SessionMessages.send_stream(@client)) 
    TestDelegate.did_authenticate_method.should be_called
  
    #### bind resource
    @client.receiving(SessionMessages.recv_postauthentication_stream_features(@client)).should respond_with(SessionMessages.send_bind_set(@client)) 
    @client.receiving(SessionMessages.recv_bind_result(@client)).should respond_with(SessionMessages.send_session_set(@client)) 
    TestDelegate.did_bind_method.should be_called
  
    #### start session and request roster
    stream_init_msgs = @client.receiving(SessionMessages.recv_session_result(@client))
    stream_init_msgs.first.should respond_with(SessionMessages.send_init_presence(@client)) 
    stream_init_msgs.last.should respond_with(RosterMessages.send_get_roster(@client)) 
    TestDelegate.did_start_session_method.should be_called
  
  end
  
  #.........................................................................................................
  should "raise exception when stream features do not include PLAIN authentication" do
  
    #### connect to server. this actually happens when client is connected here callbacks and message support are verified 
    TestDelegate.did_connect_method.should be_called
    connection_init_msgs = @client.client.connection.init_connection
    connection_init_msgs.first.should be(SessionMessages.send_supported_xml_version(@client))
    connection_init_msgs.last.should be(SessionMessages.send_stream(@client))
  
    #### receive pre authentication stream feautues which do not include plain authentication
    lambda{@client.receiving(SessionMessages.recv_preauthentication_stream_features_without_plain_SASL(@client))}.should 
      raise_error(AgentXmpp::AuthenticationFailure) 
  end
  
  #.........................................................................................................
  should "raise exception when authentication fails" do
    
    #### connect to server. this actually happens when client is connected here callbacks and message support are verified 
    TestDelegate.did_connect_method.should be_called
    connection_init_msgs = @client.client.connection.init_connection
    connection_init_msgs.first.should be(SessionMessages.send_supported_xml_version(@client))
    connection_init_msgs.last.should be(SessionMessages.send_stream(@client))
  
    #### receive pre authentication stream feautues and mechanisms and authenticate
    @client.receiving(SessionMessages.recv_preauthentication_stream_features_with_plain_SASL(@client)).should 
      respond_with(SessionMessages.send_plain_authentication(@client)) 
    lambda{@client.receiving(SessionMessages.recv_authentication_failure(@client))}.should raise_error(AgentXmpp::AuthenticationFailure) 
    
  end

  #.........................................................................................................
  should "raise exception when bind fails" do
  
    #### connect to server. this actually happens when client is connected here callbacks and message support are verified 
    TestDelegate.did_connect_method.should be_called
    connection_init_msgs = @client.client.connection.init_connection
    connection_init_msgs.first.should be(SessionMessages.send_supported_xml_version(@client))
    connection_init_msgs.last.should be(SessionMessages.send_stream(@client))
  
    #### receive pre authentication stream feautues and mechanisms and authenticate
    @client.receiving(SessionMessages.recv_preauthentication_stream_features_with_plain_SASL(@client)).should 
      respond_with(SessionMessages.send_plain_authentication(@client)) 
    @client.receiving(SessionMessages.recv_authentication_success(@client)).should respond_with(SessionMessages.send_stream(@client)) 
    TestDelegate.did_authenticate_method.should be_called
  
    #### bind resource and receive error
    @client.receiving(SessionMessages.recv_postauthentication_stream_features(@client)).should respond_with(SessionMessages.send_bind_set(@client)) 
    lambda{@client.receiving(SessionMessages.recv_bind_error(@client))}.should raise_error(AgentXmpp::AuthenticationFailure) 
  
  end

  #.........................................................................................................
  should "raise exception when steam start fails" do

      #### connect to server. this actually happens when client is connected here callbacks and message support are verified 
      TestDelegate.did_connect_method.should be_called
      connection_init_msgs = @client.client.connection.init_connection
      connection_init_msgs.first.should be(SessionMessages.send_supported_xml_version(@client))
      connection_init_msgs.last.should be(SessionMessages.send_stream(@client))
    
      #### receive pre authentication stream feautues and mechanisms and authenticate
      @client.receiving(SessionMessages.recv_preauthentication_stream_features_with_plain_SASL(@client)).should 
        respond_with(SessionMessages.send_plain_authentication(@client)) 
      @client.receiving(SessionMessages.recv_authentication_success(@client)).should respond_with(SessionMessages.send_stream(@client)) 
      TestDelegate.did_authenticate_method.should be_called
    
      #### bind resource
      @client.receiving(SessionMessages.recv_postauthentication_stream_features(@client)).should respond_with(SessionMessages.send_bind_set(@client)) 
      @client.receiving(SessionMessages.recv_bind_result(@client)).should respond_with(SessionMessages.send_session_set(@client)) 
      TestDelegate.did_bind_method.should be_called
    
      #### start session and request roster
      lambda{@client.receiving(SessionMessages.recv_session_failure(@client))}.should raise_error(AgentXmpp::AuthenticationFailure) 

  end
  
end
