##############################################################################################################
class TestClient

  #.........................................................................................................
  @client = AgentXmpp::Client.new(File.open('test/test_client/test_client.yml') {|yf| YAML::load(yf)})
  @client.connect

  ####------------------------------------------------------------------------------------------------------
  class << self 

    #.........................................................................................................
    def client
      @client
    end

    #.........................................................................................................
    def receive(msg)
      prepared_msg = msg.split(/\n/).inject("") {|p, m| p + m.strip}
      AgentXmpp.logger.info "RECV: #{prepared_msg}"
      doc = REXML::Document.new(prepared_msg).root
      doc = doc.elements.first if doc.name.eql?('stream')
      if ['presence', 'message', 'iq'].include?(doc.name)
        doc.add_namespace('jabber:client') if doc.namespace('').to_s.eql?('')
        doc = Jabber::XMPPStanza::import(doc) 
      end
      client.connection.receive(doc)
    end

  end
           
end
