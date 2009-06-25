##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  module SessionMessages

    #---------------------------------------------------------------------------------------------------------
    attr_reader :stream_features, :stream_mechanisms
    #---------------------------------------------------------------------------------------------------------
    
    #.........................................................................................................
    def authenticate(pipe)
      if stream_mechanisms.include?('PLAIN')
        Send(Jabber::SASL.new('PLAIN').auth(pipe.jid, pipe.password))
      else
        raise AgentXmppError, "PLAIN authentication required"
      end
    end
    
    #.........................................................................................................
    def bind(stanza)
      if stream_features.has_key?('bind')
        iq = Jabber::Iq.new(:set)
        bind = iq.add(REXML::Element.new('bind'))
        bind.add_namespace(stream_features['bind'])                
        resource = bind.add REXML::Element.new('resource')
        resource.text = jid.resource
        Send(iq) do |r|
          if r.type == :result and full_jid = r.first_element('//jid') and full_jid.text
            jid = Jabber::JID.new(full_jid.text) unless jid.to_s.eql?(full_jid.text)                  
            [session(stanza), broadcast_to_delegates(:did_bind, self, stanza)].smash
          elsif r.type.eql?(:error) and r.bind
            raise AgentXmppError, "resource bind failed"
          end
        end
      end                
    end
    
    #.........................................................................................................
    def session(stanza)
      if stream_features.has_key?('session')
        iq = Jabber::Iq.new(:set)
        session = iq.add REXML::Element.new('session')
        session.add_namespace stream_features['session']                
        Send(iq) do |r|
          if r.type == :result                
            [Send(Jabber::Presence.new(nil, nil, 1)), broadcast_to_delegates(:did_start_session, self, stanza)].smash
          elsif r.type.eql?(:error) and r.session
            raise AgentXmppError, "session start failed"
          end
        end
      end
    end

    #.........................................................................................................
    def init_connection(jid, starting = true)
      msg = []
      msg.push(Send("<?xml version='1.0' ?>")) if starting
      msg.push(Send("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' version='1.0' to='#{jid.domain}'>"))
    end
    
    #.........................................................................................................
    def set_stream_features(stanza)
      @stream_features, @stream_mechanisms = {}, []
      stanza.elements.each do |e|
        if e.name == 'mechanisms' and e.namespace == 'urn:ietf:params:xml:ns:xmpp-sasl'
          e.each_element('mechanism') {|mech| @stream_mechanisms.push(mech.text)}
        else
          @stream_features[e.name] = e.namespace
        end
      end
    end
    
  #### SessionMessages
  end
  
#### AgentXmpp
end
