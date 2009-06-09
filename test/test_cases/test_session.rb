##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestSession < Test::Unit::TestCase

  #.........................................................................................................
  should "authenticate with PLAIN SASL authentication when stream features includes PLAIN authentication" do
    TestDelegate.did_connect_flag.should be(true)
    stram_init_msgs = TestClient.client.connection.init_connection
    stram_init_msgs.first.should be(Session.send_supported_xml_version)
    stram_init_msgs.last.should be(Session.send_stream_init)
    TestClient.receive(Session.recv_preauthentication_stream_features_with_plain_SASL).should respond_with(Session.send_plain_authentication) 
    TestClient.receive(Session.recv_authentication_success).should respond_with(Session.send_stream_init) 
    TestClient.receive(Session.recv_postauthentication_stream_features).should respond_with(Session.send_bind) 
    TestClient.receive(Session.recv_bind_success).should respond_with(Session.send_session_init) 
  end

  #.........................................................................................................
  should "should not authenticate when stream features do not includes PLAIN authentication" do
  end

end
