# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class Iq < XMPPStanza

      #####-----------------------------------------------------------------------------------------------------
      class << self
        
        #.........................................................................................................
        def get_client_version(contact_jid, pipe)
          iq = Xmpp::Iq.new(:get, contact_jid)
          iq.query = Xmpp::Version::IqQueryVersion.new
          Send(iq) do |r|
            if (r.type == :result) && r.query.kind_of?(Xmpp::Version::IqQueryVersion)
              pipe.broadcast_to_delegates(:did_receive_client_version_result, pipe, r.from, r.query)
            end
          end
        end

        #.........................................................................................................
        def client_version_response(request)
          iq = Xmpp::Iq.new(:result, request.from.to_s)
          iq.id = request.id unless request.id.nil?
          iq.query = Xmpp::Version::IqQueryVersion.new
          iq.query.set_iname(AgentXmpp::AGENT_XMPP_NAME).set_version(AgentXmpp::VERSION).set_os(AgentXmpp::OS_VERSION)
          Send(iq)
        end
        
        #.........................................................................................................
        def bind(stanza, pipe)
          if pipe.stream_features.has_key?('bind')
            iq = Iq.new(:set)
            bind = iq.add(REXML::Element.new('bind'))
            bind.add_namespace(pipe.stream_features['bind'])                
            resource = bind.add REXML::Element.new('resource')
            resource.text = pipe.jid.resource
            Send(iq) do |r|
              if r.type == :result and full_jid = r.first_element('//jid') and full_jid.text
                pipe.jid = JID.new(full_jid.text) unless pipe.jid.to_s.eql?(full_jid.text)                  
                [session(stanza, pipe), pipe.broadcast_to_delegates(:did_bind, pipe, stanza)].smash
              elsif r.type.eql?(:error) and r.bind
                raise AgentXmppError, "resource bind failed"
              end
            end
          end                
        end

        #.........................................................................................................
        def session(stanza, pipe)
          if pipe.stream_features.has_key?('session')
            iq = Iq.new(:set)
            session = iq.add REXML::Element.new('session')
            session.add_namespace(pipe.stream_features['session'])
            Send(iq) do |r|
              if r.type == :result                
                [Send(Presence.new(nil, nil, 1)), pipe.broadcast_to_delegates(:did_start_session, pipe, stanza)].smash
              elsif r.type.eql?(:error) and r.session
                raise AgentXmppError, "session start failed"
              end
            end
          end
        end
      
        #.......................................................................................................
        def new_query(type = nil, to = nil)
          iq = Iq.new(type, to)
          query = IqQuery.new
          iq.add(query)
          iq
        end

        #.......................................................................................................
        def new_authset(jid, password)
          iq = Iq.new(:set)
          query = IqQuery.new
          query.add_namespace('jabber:iq:auth')
          query.add(REXML::Element.new('username').add_text(jid.node))
          query.add(REXML::Element.new('password').add_text(password))
          query.add(REXML::Element.new('resource').add_text(jid.resource)) if not jid.resource.nil?
          iq.add(query)
          iq
        end

        #.......................................................................................................
        def new_authset_digest(jid, session_id, password)
          iq = Iq.new(:set)
          query = IqQuery.new
          query.add_namespace('jabber:iq:auth')
          query.add(REXML::Element.new('username').add_text(jid.node))
          query.add(REXML::Element.new('digest').add_text(Digest::SHA1.hexdigest(session_id + password)))
          query.add(REXML::Element.new('resource').add_text(jid.resource)) if not jid.resource.nil?
          iq.add(query)
          iq
        end

        #.......................................................................................................
        def new_register(username=nil, password=nil)
          iq = Iq.new(:set)
          query = IqQuery.new
          query.add_namespace('jabber:iq:register')
          query.add(REXML::Element.new('username').add_text(username)) if username
          query.add(REXML::Element.new('password').add_text(password)) if password
          iq.add(query)
          iq
        end

        #.......................................................................................................
        def new_registerget
          iq = Iq.new(:get)
          query = IqQuery.new
          query.add_namespace('jabber:iq:register')
          iq.add(query)
          iq
        end

        #.......................................................................................................
        def new_rosterget
          iq = Iq.new(:get)
          query = IqQuery.new
          query.add_namespace('jabber:iq:roster')
          iq.add(query)
          iq
        end

        #.......................................................................................................
        def new_browseget
          iq = Iq.new(:get)
          query = IqQuery.new
          query.add_namespace('jabber:iq:browse')
          iq.add(query)
          iq
        end

        #.......................................................................................................
        def new_rosterset
          iq = Iq.new(:set)
          query = IqQuery.new
          query.add_namespace('jabber:iq:roster')
          iq.add(query)
          iq
        end
      
      #### self
      end

      #.......................................................................................................
      name_xmlns 'iq', 'jabber:client'
      force_xmlns true

      #.......................................................................................................
      @@element_classes = {}

      #.......................................................................................................
      def initialize(type = nil, to = nil)
        super()
        if not to.nil?
          set_to(to)
        end
        if not type.nil?
          set_type(type)
        end
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
