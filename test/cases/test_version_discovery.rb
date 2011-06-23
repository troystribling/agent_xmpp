##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestClientVersionDiscovery < Test::Unit::TestCase

  #.........................................................................................................
  # def setup
  #   @troy = AgentXmpp::Xmpp::Jid.new('troy@nowhere.com/home')
  #   @noone = AgentXmpp::Xmpp::Jid.new('noone@nowhere.com/nothing')
  #   @config = {'jid' => 'test@nowhere.com', 'roster' =>[@troy.bare.to_s], 'password' => 'nopass'}
  #   @client = TestClient.new(@config)
  #   test_init_roster(@client)
  #   @delegate = @client.new_delegate
  # end
  
  ####-------------------------------------------------------------------------------------------------------
  # context "on receiving a presence message of type=available from a jid in configured roster" do
  # 
  #   #.........................................................................................................
  #   setup do
  #     AgentXmpp::Xmpp::IdGenerator.set_gen_id([1,2])
  #     @delegate.on_version_get_method.should_not be_called
  #     @delegate.on_version_result_method.should_not be_called
  #     AgentXmpp::Roster.find_by_jid(@troy).should be_nil
  #     @client.receiving(PresenceMessages.recv_presence_available(@client, @troy.to_s)).should \
  #       respond_with(VersionDiscoveryMessages.send_iq_get_query_version(@client, @troy.to_s))
  #     AgentXmpp::Roster.find_by_jid(@troy).should_not be_nil
  #   end  
  # 
  #   #.........................................................................................................
  #   should "send a client version request to that jid and do nothing if the result is an error" do
  #     @client.receiving(VersionDiscoveryMessages.recv_iq_result_query_version(@client, @troy.to_s)).should not_respond
  #     AgentXmpp::Roster.has_version?(@troy).should be(true)
  #     @delegate.on_version_result_method.should be_called
  #   end
  #       
  #   #.........................................................................................................
  #   should "respond to client version requests from that jid" do
  #     @client.receiving(VersionDiscoveryMessages.recv_iq_result_query_version(@client, @troy.to_s)).should not_respond
  #     AgentXmpp::Roster.has_version?(@troy).should be(true)
  #     @delegate.on_version_result_method.should be_called
  #     @client.receiving(VersionDiscoveryMessages.recv_iq_get_query_version(@client, @troy.to_s)).should \
  #       respond_with(VersionDiscoveryMessages.send_iq_result_query_version(@client, @troy.to_s))
  #     @delegate.on_version_get_method.should be_called
  #   end
  #   
  #   #.........................................................................................................
  #   should "send a client version request to that jid and update roster with result version information" do
  #     @delegate.on_version_error_method.should_not be_called
  #     @client.receiving(VersionDiscoveryMessages.recv_iq_error_query_version(@client, @troy.to_s)).should not_respond
  #     AgentXmpp::Roster.has_version?(@troy).should be(false)
  #     @delegate.on_version_error_method.should be_called
  #   end
  #     
  # end
          
  #.........................................................................................................
  # should "not respond to client version requests from jids not in configured roster" do
  #   @delegate.on_version_get_method.should_not be_called
  #   AgentXmpp::Contact.has_jid?(@noone).should be(false)
  #   @client.receiving(VersionDiscoveryMessages.recv_iq_get_query_version(@client, @noone.to_s)).should not_respond
  #   @delegate.on_version_get_method.should be_called
  # end
    
end

