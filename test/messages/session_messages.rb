##############################################################################################################
module SessionMessages

  #####-------------------------------------------------------------------------------------------------------
  class << self
    
    #### received messages    
    #.........................................................................................................
    def recv_preauthentication_stream_features_with_plain_SASL(client)
      <<-MSG
        <stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='1' from='#{client.client.jid.domain}' version='1.0' xml:lang='en'>
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
    def recv_preauthentication_stream_features_without_plain_SASL(client)
      <<-MSG
        <stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='1' from='#{client.client.jid.domain}' version='1.0' xml:lang='en'>
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
    def recv_auth_success(client)
      "<success xmlns='urn:ietf:params:xml:ns:xmpp-sasl'/>"
    end

    #.........................................................................................................
    def recv_auth_failure(client)
      <<-MSG
        <failure xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>
          <not-authorized/>
        </failure>
      MSG
     end
  
    #.........................................................................................................
    def recv_postauthentication_stream_features(client)
      <<-MSG
        <stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='1' from='#{client.client.jid.domain}' version='1.0' xml:lang='en'>
          <stream:features>
            <bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'/>
            <session xmlns='urn:ietf:params:xml:ns:xmpp-session'/>
          </stream:features>
        </stream:stream>
      MSG
    end

    #.........................................................................................................
    def recv_iq_result_bind(client)
      <<-MSG
        <iq id='1' type='result' xmlns='jabber:client'>
          <bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'>
            <jid>#{client.client.jid.to_s}</jid>
          </bind>
        </iq>
       MSG
    end

    #.........................................................................................................
    def recv_iq_result_session(client)
      <<-MSG
        <iq type='result' id='2' xmlns='jabber:client'>
          <session xmlns='urn:ietf:params:xml:ns:xmpp-session'/>
        </iq>
       MSG
    end

    #.........................................................................................................
    def recv_error_bind(client)
      <<-MSG
        <iq type='error' id='1' xmlns='jabber:client'>
          <bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'>
            <resource>someresource</resource>
          </bind>
          <error type='cancel'>
            <not-allowed xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
          </error>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_error_session(client)
      <<-MSG
        <iq from='#{client.client.jid.domain}' type='error' id='2' xmlns='jabber:client'>
          <session xmlns='urn:ietf:params:xml:ns:xmpp-session'/>
          <error type='wait'>
            <internal-server-error xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
          </error>
        </iq>
      MSG
    end
  
    #### sent messages    
    #.........................................................................................................
    def send_supported_xml_version(client)
      "<?xml version='1.0' ?>"
    end

    #.........................................................................................................
    def send_stream(client)
      "<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' version='1.0' to='plan-b.ath.cx'>"
    end

    #.........................................................................................................
    def send_auth_plain(client)
      "<auth mechanism='PLAIN' xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>"
    end
  
    #.........................................................................................................
    def send_iq_set_bind(client)
      <<-MSG
        <iq id='1' type='set' xmlns='jabber:client'>
          <bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'>
            <resource>#{client.client.jid.resource}</resource>
          </bind>
        </iq>
      MSG
    end

    #.........................................................................................................
    def send_iq_set_session(client)
      <<-MSG
        <iq id='2' type='set' xmlns='jabber:client'>
          <session xmlns='urn:ietf:params:xml:ns:xmpp-session'/>
        </iq>
      MSG
    end

    #.........................................................................................................
    def send_presence_init(client)
      <<-MSG
        <presence xmlns='jabber:client'>
          <priority>1</priority>
        </presence>
      MSG
    end

  ## self  
  end

#### SessionMessages      
end
