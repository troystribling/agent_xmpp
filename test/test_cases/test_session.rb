##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestSession < Test::Unit::TestCase

  #.........................................................................................................
  def setup
    @client = TestClient.new
  end
  
  #.........................................................................................................
  should "authenticate with PLAIN SASL authentication when stream features includes PLAIN authentication" do
    TestDelegate.did_connect_method.should be_called
    stream_init_msgs = @client.client.connection.init_connection
    stream_init_msgs.first.should be(SessionMessages.send_supported_xml_version(@client))
    stream_init_msgs.last.should be(SessionMessages.send_stream_init(@client))
    @client.receiving(SessionMessages.recv_preauthentication_stream_features_with_plain_SASL(@client)).should 
      respond_with(SessionMessages.send_plain_authentication(@client)) 
    @client.receiving(SessionMessages.recv_authentication_success(@client)).should respond_with(SessionMessages.send_stream_init(@client)) 
    @client.receiving(SessionMessages.recv_postauthentication_stream_features(@client)).should respond_with(SessionMessages.send_bind(@client)) 
    @client.receiving(SessionMessages.recv_bind_success(@client)).should respond_with(SessionMessages.send_session_init(@client)) 
  end

  #.........................................................................................................
  should "should not authenticate when stream features do not includes PLAIN authentication" do
  end

end
