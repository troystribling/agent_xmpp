##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestErrors < Test::Unit::TestCase

  #.........................................................................................................
  def setup
    @client = TestClient.new()
    test_init_roster(@client)
    @delegate = @client.new_delegate
    @test = AgentXmpp::Xmpp::Jid.new('test@plan-b.ath.cx/home')
  end
  
  #.........................................................................................................
  should "respond with feature-not-implemented when unsupported messages are received" do
    @delegate.on_unsupported_message_method.should_not be_called
    @client.receiving(ErrorMessages.recv_iq_error(@client, @test.to_s)).should \
      respond_with(ErrorMessages.send_iq_error(@client, @test.to_s))
    @delegate.on_unsupported_message_method.should be_called
  end
  
end

