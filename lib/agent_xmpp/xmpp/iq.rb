# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class Iq < XMPPStanza

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
      def type
        super.to_sym
      end

      #.......................................................................................................
      def type=(v)
        super(v.to_s)
      end

      #.......................................................................................................
      def set_type(v)
        self.type = v
        self
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

      #.......................................................................................................
      def Iq.new_query(type = nil, to = nil)
        iq = Iq.new(type, to)
        query = IqQuery.new
        iq.add(query)
        iq
      end

      #.......................................................................................................
      def Iq.new_authset(jid, password)
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
      def Iq.new_authset_digest(jid, session_id, password)
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
      def Iq.new_register(username=nil, password=nil)
        iq = Iq.new(:set)
        query = IqQuery.new
        query.add_namespace('jabber:iq:register')
        query.add(REXML::Element.new('username').add_text(username)) if username
        query.add(REXML::Element.new('password').add_text(password)) if password
        iq.add(query)
        iq
      end

      #.......................................................................................................
      def Iq.new_registerget
        iq = Iq.new(:get)
        query = IqQuery.new
        query.add_namespace('jabber:iq:register')
        iq.add(query)
        iq
      end

      #.......................................................................................................
      def Iq.new_rosterget
        iq = Iq.new(:get)
        query = IqQuery.new
        query.add_namespace('jabber:iq:roster')
        iq.add(query)
        iq
      end

      #.......................................................................................................
      def Iq.new_browseget
        iq = Iq.new(:get)
        query = IqQuery.new
        query.add_namespace('jabber:iq:browse')
        iq.add(query)
        iq
      end

      #.......................................................................................................
      def Iq.new_rosterset
        iq = Iq.new(:set)
        query = IqQuery.new
        query.add_namespace('jabber:iq:roster')
        iq.add(query)
        iq
      end
      
    #### Iq
    end

  #### XMPP
  end

#### AgentXmpp
end
