# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class IqCommand < Iq

      #####-------------------------------------------------------------------------------------------------------
      class << self
        
        #.........................................................................................................
        def result(args)
          iq = Xmpp::Iq.new(:result, args[:to])
          iq.id = args[:id] unless args[:id].nil?
          iq.command = new(args[:node], 'completed')
          iq.command << args[:payload]
          Send(iq)      
        end
        
      #### self
      end

      #.....................................................................................................
      name_xmlns 'command', 'http://jabber.org/protocol/commands'

      #.....................................................................................................
      def initialize(node=nil, action=nil)
        super()
        set_node(node)
        set_action(action)
      end

      #.....................................................................................................
      def node
        attributes['node']
      end

      #.....................................................................................................
      def node=(v)
        attributes['node'] = v
      end

      #.....................................................................................................
      def set_node(v)
        self.node = v
        self
      end

      #.....................................................................................................
      def sessionid
        attributes['sessionid']
      end

      #.....................................................................................................
      def sessionid=(v)
        attributes['sessionid'] = v
      end

      #.....................................................................................................
      def set_sessionid(v)
        self.sessionid = v
        self
      end

      #.....................................................................................................
      def action
        attributes['action'].to_sym
      end

      #.....................................................................................................
      def action=(v)
        attributes['action'] = v.to_s
      end

      #.....................................................................................................
      def set_action(v)
        self.action = v
        self
      end

      #.....................................................................................................
      def status
        attributes['status'].to_sym
      end

      #.....................................................................................................
      def status=(v)
        attributes['status'] = v.to_s
      end

      #.....................................................................................................
      def set_status(v)
        self.status = v
        self
      end

      #.....................................................................................................
      def actions
        first_element('actions')
      end

    #### IqCommand
    end

  #### XMPP
  end
  
#### AgentXmpp
end