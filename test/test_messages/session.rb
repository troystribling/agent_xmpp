##############################################################################################################
module Session

  #####-------------------------------------------------------------------------------------------------------
  class << self
    
    #### received messages    
    #.........................................................................................................
    def recv_preauthentication_stream_features_with_plain_SASL
      <<-MSG
        <stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='1' from='#{TestClient.client.jid.domain}' version='1.0' xml:lang='en'>
          <stream:features>
            <mechanisms xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>
              <mechanism>DIGEST-MD5</mechanism>
              <mechanism>PLAIN</mechanism>
            </mechanisms>
          <register xmlns='http://jabber.org/features/iq-register'/>
          </stream:features>
        </stream:stream>
      MSG
    end

    #.........................................................................................................
    def recv_preauthentication_stream_features_without_plain_SASL
      <<-MSG
        <stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='1' from='#{TestClient.client.jid.domain}' version='1.0' xml:lang='en'>
          <stream:features>
            <mechanisms xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>
              <mechanism>DIGEST-MD5</mechanism>
            </mechanisms>
          <register xmlns='http://jabber.org/features/iq-register'/>
          </stream:features>
        </stream:stream>
      MSG
    end

    #.........................................................................................................
    def recv_authentication_success
      "<success xmlns='urn:ietf:params:xml:ns:xmpp-sasl'/>"
    end

    #.........................................................................................................
    def recv_authentication_failed
      "<failure xmlns='urn:ietf:params:xml:ns:xmpp-sasl'/>"
    end
  
    #.........................................................................................................
    def recv_postauthentication_stream_features
      <<-MSG
        <stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='1' from='#{TestClient.client.jid.domain}' version='1.0' xml:lang='en'>
          <stream:features>
            <bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'/>
            <session xmlns='urn:ietf:params:xml:ns:xmpp-session'/>
          </stream:features>
        </stream:stream>
      MSG
    end

    #.........................................................................................................
    def recv_bind_success
      <<-MSG
        <iq id='1327' type='result'>
          <bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'>
            <jid>#{TestClient.client.jid.to_s}</jid>
          </bind>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_bind_failed
    end

    #.........................................................................................................
    def recv_session_start_succcess
    end

    #.........................................................................................................
    def recv_session_start_failed
    end
  
    #### sent messages    
    #.........................................................................................................
    def send_supported_xml_version
      "<?xml version='1.0' ?>"
    end

    #.........................................................................................................
    def send_stream_init
      "<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' version='1.0' to='plan-b.ath.cx'>"
    end

    #.........................................................................................................
    def send_plain_authentication
      "<auth mechanism='PLAIN' xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>"
    end
  
    #.........................................................................................................
    def send_bind
      <<-MSG
        <iq id='1327' type='set' xmlns='jabber:client'>
          <bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'>
            <resource>#{TestClient.client.jid.resource}</resource>
          </bind>
        </iq>
      MSG
    end

    #.........................................................................................................
    def send_session_start
      <<-MSG
        <iq id='2144' type='set' xmlns='jabber:client'>
          <session xmlns='urn:ietf:params:xml:ns:xmpp-session'/>
        </iq>
      MSG
    end

    #.........................................................................................................
    def send_init_presence
      <<-MSG
        <presence xmlns='jabber:client'>
          <priority>1</priority>
        </presence>
      MSG
    end
     
  end
      
end
