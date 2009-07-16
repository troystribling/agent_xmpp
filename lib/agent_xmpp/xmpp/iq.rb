# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class Iq < Stanza

      #.....................................................................................................
      name_xmlns 'iq', 'jabber:client'
      xmpp_child :query, :error, :pubsub, :command, :bind, :session

      #####-----------------------------------------------------------------------------------------------------
      class << self
        
        #.........................................................................................................
        def bind(pipe)
          iq = new_bind(pipe.jid)
          Send(iq) do |r|
            if r.type == :result and full_jid = r.first_element('//jid') and full_jid.text
              pipe.jid = JID.new(full_jid.text)                
              pipe.broadcast_to_delegates(:did_bind, pipe)
            elsif r.type.eql?(:error) and r.bind
              raise AgentXmppError, "resource bind failed"
            end
          end
        end

        #.........................................................................................................
        def session(pipe)
          iq = new_session
          Send(iq) do |r|
            if r.type == :result                
              pipe.broadcast_to_delegates(:did_start_session, pipe)
            elsif r.type.eql?(:error) and r.session
              raise AgentXmppError, "session start failed"
            end
          end
        end
      
      private
        
        #.......................................................................................................
        def new_bind(jid)
          iq = Iq.new(:set)
          iq.bind = REXML::Element.new('bind')
          iq.bind.add_namespace('urn:ietf:params:xml:ns:xmpp-bind')                
          resource = iq.bind.add(REXML::Element.new('resource'))
          resource.text = jid.resource
          iq
        end

        #.......................................................................................................
        def new_session
          iq = Iq.new(:set)
          iq.session =REXML::Element.new('session')
          iq.session.add_namespace('urn:ietf:params:xml:ns:xmpp-session')
          iq
        end
      
      #### self
      end

      #.......................................................................................................
      def initialize(type = nil, to = nil)
        super()
        self.to = to unless to.nil?
        self.type = type unless type.nil?
      end

      #.......................................................................................................
      def queryns
        (e = first_element('query')).nil? ? nil : e.namespace
      end

    #### Iq
    end

    #####-------------------------------------------------------------------------------------------------------
    class IqQuery < Element
      name_xmlns 'query'
    end

  #### XMPP
  end

#### AgentXmpp
end
