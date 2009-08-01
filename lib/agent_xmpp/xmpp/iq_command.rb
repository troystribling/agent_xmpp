# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class IqCommand < Element

      #.....................................................................................................
      name_xmlns 'command', 'http://jabber.org/protocol/commands'
      xmpp_attribute :node, :sessionid
      xmpp_attribute :action, :status, :sym => true
      xmpp_child :actions, :x

      #####-------------------------------------------------------------------------------------------------------
      class << self
        
        #.........................................................................................................
        def result(args)
          iq = Iq.new(:result, args[:to])
          iq.id = args[:id] unless args[:id].nil?
          iq.command = new(args[:node])
          iq.command.status = 'completed'
          iq.command << args[:payload] unless args[:payload].nil?
          Send(iq)      
        end
        
      #### self
      end

      #.....................................................................................................
      def initialize(node=nil, action=nil)
        super()
        self.node = node if node
        self.action = action if action
      end

    #### IqCommand
    end

  #### XMPP
  end
  
#### AgentXmpp
end
