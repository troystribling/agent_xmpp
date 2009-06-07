##############################################################################################################
class Test::Unit::TestCase

  #.........................................................................................................
  @@client = AgentXmpp::Client.new(File.open('test/test_client/test_client.yml') {|yf| YAML::load(yf)})
  @@client.connect

  #.........................................................................................................
  def client
    @@client
  end

  #.........................................................................................................
  def receive(msg)
    msg = prepare_msg(msg)
    AgentXmpp.logger.info "RECV: #{msg}"
    client.connection.receive(REXML::Document.new(msg))
  end

  #.........................................................................................................
  def stream_receive(msg)
    msg = prepare_msg(msg)
    AgentXmpp.logger.info "RECV: #{msg}"
    client.connection.receive(REXML::Document.new(msg).root.elements.first)
  end

  #.........................................................................................................
  def prepare_msg(msg)
    msg.split(/\n/).inject("") {|p, m| p + m.strip}
  end
           
end
