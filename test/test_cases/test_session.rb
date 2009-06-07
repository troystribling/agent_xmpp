##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestSession < Test::Unit::TestCase

  #.........................................................................................................
  should "authenticate with PLAIN SASL authentication when stream features includes PLAIN authentication" do
    stream_receive(recv_preauthentication_stream_features_with_plain_SASL).include?(send_plain_authentication).should be(true) 
  end

  #.........................................................................................................
  should "should not authenticate when stream features do not includes PLAIN authentication" do
  end

end
