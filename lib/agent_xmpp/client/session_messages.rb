##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class AuthenticationFailure < Exception; end
  
  #####-------------------------------------------------------------------------------------------------------
  module SessionMessages

    #---------------------------------------------------------------------------------------------------------
    attr_reader :stream_features, :stream_mechanisms
    #---------------------------------------------------------------------------------------------------------
    
    #.........................................................................................................
    def authenticate
      if stream_mechanisms.include?('PLAIN')
        Jabber::SASL.new(self, 'PLAIN').auth(password)
      else
        raise AuthenticationFailure, "PLAIN authentication not supported"
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
        send(iq) do |r|
          if r.type == :result and full_jid = r.first_element('//jid') and full_jid.text
            jid = Jabber::JID.new(full_jid.text) unless jid.to_s.eql?(full_jid.text)      
            [broadcast_to_delegates(:did_bind, self, stanza), session(stanza)].flatten
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
        send(iq) do |r|
          if r.type == :result                
            [broadcast_to_delegates(:did_authenticate, self, stanza), send(Jabber::Presence.new(nil, nil, 1))].flatten
          end
        end
      end
    end

    #.........................................................................................................
    def init_connection(starting=true)
      result = []
      result.push(send("<?xml version='1.0' ?>")) if starting
      result.push(send("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' version='1.0' to='#{jid.domain}'>"))
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
