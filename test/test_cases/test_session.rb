##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestSession < Test::Unit::TestCase

  #.........................................................................................................
  should "authenticate with PLAIN SASL authentication when stream features includes PLAIN authentication" do
    TestDelegate.did_connect_flag.should be(true)
    TestClient.client.connection.init_connection.first.should be(Session.send_supported_xml_version)
    TestClient.client.connection.init_connection.last.should be(Session.send_stream_init)
    TestClient.stream_receive(Session.recv_preauthentication_stream_features_with_plain_SASL).include?(Session.send_plain_authentication).should be(true) 
    TestClient.receive(Session.recv_authentication_success).first.should be(Session.send_stream_init) 
  end

  #.........................................................................................................
  should "should not authenticate when stream features do not includes PLAIN authentication" do
  end

end
