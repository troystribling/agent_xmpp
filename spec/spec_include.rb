##############################################################################################################
module SpecInclude
   
  #.......................................................................................................................................................................
  let(:client){AgentXmpp::MessagePipe.new}
  let(:agent_jid){AgentXmpp::Xmpp::Jid.new("#{@agent}/ubuntu")}
  let(:admin){AgentXmpp::Xmpp::Jid.new("#{@admin}/there")}
  let(:user){AgentXmpp::Xmpp::Jid.new("#{@user}/where")}
  let(:delegate){client.add_delegate(TestDelegate.new)}

  #.......................................................................................................................................................................
  def client_should_send_data(data)
    prepared_data = SpecUtils.prepare_msg([data].flatten).join
    client.connection.should_receive(:send_data).once.with(prepared_data).and_return(prepared_data)
  end

  #.......................................................................................................................................................................
  def client_receiving(stanza)
    parsed_stanza = SpecUtils.parse_stanza(stanza)
    client.receive(parsed_stanza)
  end

  #.......................................................................................................................................................................
  before(:each) do
    client.connection = mock('connection')
    client.connection.stub!(:reset_parser)
    client.connection.stub!(:error?).and_return(false)    
    delegate    
  end

end