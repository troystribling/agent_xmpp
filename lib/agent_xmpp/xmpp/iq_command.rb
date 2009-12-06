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
        def send_command(args, &blk)
          iq = Xmpp::Iq.new(args[:iq_type] || :set, args[:to])
          iq.id = args[:id] unless args[:id].nil?
          iq.command = new(args[:node])
          iq.command.action = args[:action] unless args[:action].nil? 
          iq.command.status = args[:status] unless args[:status].nil? 
          iq.command.sessionid = args[:sessionid] unless args[:sessionid].nil?
          iq.command << args[:payload] unless args[:payload].nil?
          if blk
            Send(iq) do |r|  
              AgentXmpp.logger.info "RECEIVED RESPONSE: #{r.type} from #{r.from}"
              blk.call(r.type, (r.type.eql?(:result) and r.command and r.command.x) ? r.command.x.to_native : nil)
            end
          else; Send(iq); end               
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
