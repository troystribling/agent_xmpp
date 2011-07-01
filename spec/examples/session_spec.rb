require 'spec_helper'

##########################################################################################################################################################################
describe 'session protocol' do
##########################################################################################################################################################################

  #.......................................................................................................................................................................
  let(:client) {AgentXmpp::MessagePipe.new}
  let(:agent_jid) {AgentXmpp::Xmpp::Jid.new('agent@nowhere.com/testing')}
  let(:admin) {AgentXmpp::Xmpp::Jid.new('troy@somewhere.com/there')}
  let(:user) {AgentXmpp::Xmpp::Jid.new('vanessa@thhee.com/where')}
  let(:config) {{'jid' => agent_jid.to_s, 'password' => 'pass', 'roster' => [{'jid' => admin, 'groups' => ['admin']}, {'jid' => user, 'groups' => ['user']}]}}

  #.......................................................................................................................................................................
  before(:each) do
    client.connection = mock('connection')
    client.connection.stub!(:reset_parser)
    client.connection.stub!(:error?).and_return(false)    
    AgentXmpp::Boot.stub!(:boot).and_return(nil)
    AgentXmpp.config = config
  end
  
#.........................................................................................................
# should "authenticate with PLAIN SASL authentication when stream features includes PLAIN authentication" do
# 
#   #### connect to server
#   @client.client.pipe.connection_completed.should \
#     respond_with(SessionMessages.send_supported_xml_version(@client), SessionMessages.send_stream(@client))
# 
#   #### receive pre authentication stream feautues and mechanisms and authenticate
#   @delegate.on_authenticate_method.should_not be_called
#   @delegate.on_preauthenticate_features_method.should_not be_called
#   @client.receiving(SessionMessages.recv_preauthentication_stream_features_with_plain_SASL(@client)).should \
#     respond_with(SessionMessages.send_auth_plain(@client)) 
#   @client.receiving(SessionMessages.recv_auth_success(@client)).should respond_with(SessionMessages.send_stream(@client)) 
#   @delegate.on_preauthenticate_features_method.should be_called
#   @delegate.on_authenticate_method.should be_called
# 
#   #### bind resource
#   @delegate.on_bind_method.should_not be_called
#   @delegate.on_postauthenticate_features_method.should_not be_called
#   @client.receiving(SessionMessages.recv_postauthentication_stream_features(@client)).should respond_with(SessionMessages.send_iq_set_bind(@client)) 
#   @client.receiving(SessionMessages.recv_iq_result_bind(@client)).should respond_with(SessionMessages.send_iq_set_session(@client)) 
#   @delegate.on_postauthenticate_features_method.should be_called
#   @delegate.on_bind_method.should be_called
# 
#   #### start session and request roster
#   @delegate.on_start_session_method.should_not be_called
#   @client.receiving(SessionMessages.recv_iq_result_session(@client)).should \
#     respond_with(SessionMessages.send_presence_init(@client), RosterMessages.send_iq_get_query_roster(@client),
#                  ServiceDiscoveryMessages.send_iq_get_query_discoinfo(@client, @client.jid.domain)) 
#   @delegate.on_start_session_method.should be_called
# 
# end


  ####**********************************************************************************************************************************************************************
  context 'when TCP connection to server is established' do

    ####--------------------------------------------------------------------------------------------------------------------------------------------------------------------
    it 'should send XML version message and stream initialization message' do
      messages = [SessionMessages.send_supported_xml_version(agent_jid), SessionMessages.send_stream(agent_jid)]
      client.connection.should_receive(:send_data).once.with(messages.first).and_return(messages.first)
      client.connection.should_receive(:send_data).once.with(messages.last).and_return(messages.last)
      client.connection_completed.should == messages
    end
  
  end

  ####**********************************************************************************************************************************************************************
  context 'when connection status is offline' do
  end

  ####**********************************************************************************************************************************************************************
  context 'when connection status is authenticated' do
  end
  
end
