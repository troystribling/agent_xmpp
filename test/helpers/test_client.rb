##############################################################################################################
class TestClient

  #.........................................................................................................
  attr_reader :client

  #.........................................................................................................
  def initialize(config = nil)
    @config = config || File.open('test/helpers/agent_xmpp.yml') {|yf| YAML::load(yf)}
    @client = AgentXmpp::Client.new(@config)
    @client.connect
  end

  #.........................................................................................................
  def connection
    @client.connection
  end
  
  #.........................................................................................................
  def roster
    @client.pipe.roster
  end

  #.........................................................................................................
  def new_delegate
    @client.remove_delegate(@delegate) unless @delegate.nil?
    @delegate = TestDelegate.new
    @client.add_delegate(@delegate)
    @delegate
  end
    
  #.........................................................................................................
  def receiving(msg)
    prepared_msg = msg.split(/\n/).inject("") {|p, m| p + m.strip}
    doc = REXML::Document.new(prepared_msg).root
    doc = doc.elements.first if doc.name.eql?('stream')
    if ['presence', 'message', 'iq'].include?(doc.name)
      doc = AgentXmpp::Xmpp::Stanza::import(doc) 
    end
    client.connection.receive(doc)
  end

end
