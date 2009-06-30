# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class Iq < Stanza

      #.....................................................................................................
      name_xmlns 'iq', 'jabber:client'
      force_xmlns true

      #####-----------------------------------------------------------------------------------------------------
      class << self
        
        #.........................................................................................................
        def bind(stanza, pipe)
          iq = new_bind(pipe.jid)
          Send(iq) do |r|
            if r.type == :result and full_jid = r.first_element('//jid') and full_jid.text
              pipe.jid = JID.new(full_jid.text)                
              [session(stanza, pipe), pipe.broadcast_to_delegates(:did_bind, pipe, stanza)].smash
            elsif r.type.eql?(:error) and r.bind
              raise AgentXmppError, "resource bind failed"
            end
          end
        end

        #.........................................................................................................
        def session(stanza, pipe)
          iq = new_session
          Send(iq) do |r|
            if r.type == :result                
              [Send(Presence.new(nil, nil, 1)), pipe.broadcast_to_delegates(:did_start_session, pipe, stanza)].smash
            elsif r.type.eql?(:error) and r.session
              raise AgentXmppError, "session start failed"
            end
          end
        end
      
      private
        
        #.......................................................................................................
        def new_bind(jid)
          iq = Iq.new(:set)
          bind = iq.add(REXML::Element.new('bind'))
          bind.add_namespace('urn:ietf:params:xml:ns:xmpp-bind')                
          resource = bind.add(REXML::Element.new('resource'))
          resource.text = jid.resource
          iq
        end

        #.......................................................................................................
        def new_session
          iq = Iq.new(:set)
          session = iq.add REXML::Element.new('session')
          session.add_namespace('urn:ietf:params:xml:ns:xmpp-session')
          iq
        end
      
      #### self
      end

      #.......................................................................................................
      def initialize(type = nil, to = nil)
        super()
        set_to(to) unless to.nil?
        set_type(type) unless type.nil?
      end

      #.......................................................................................................
      def query
        first_element('query')
      end

      #.......................................................................................................
      def query=(newquery)
        delete_elements(newquery.name)
        add(newquery)
      end

      #.......................................................................................................
      def queryns
        e = first_element('query')
        if e
          return e.namespace
        else
          return nil
        end
      end

      #.......................................................................................................
      def pubsub
        first_element('pubsub')
      end

      #.......................................................................................................
      def command
        first_element("command")
      end

      #.....................................................................................................
      def command=(newcommand)
        delete_elements(newcommand.name)
        add(newcommand)
      end

      #.....................................................................................................
      def bind
        first_element('bind')
      end

      #.....................................................................................................
      def session
        first_element('session')
      end
      
    #### Iq
    end

  #### XMPP
  end

#### AgentXmpp
end
