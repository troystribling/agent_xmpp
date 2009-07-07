# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class IqDiscoItems < IqQuery

      #.........................................................................................................
      name_xmlns 'query', 'http://jabber.org/protocol/disco#items'

      #####-----------------------------------------------------------------------------------------------------
      class << self

        #.........................................................................................................
        def get(pipe, to=nil)
          iq = Iq.new(:get, to)
          iq.query = new
          Send(iq) do |r|
            if (r.type == :result) && r.query.kind_of?(Xmpp::IqDiscoItems)
              pipe.broadcast_to_delegates(:did_receive_discoitems_result, pipe, r)
            elsif r.type.eql?(:error)
              pipe.broadcast_to_delegates(:did_receive_discoitems_error, pipe, r)
            end
          end
        end
        
        #.........................................................................................................
        def result(pipe, request)
          iq = Xmpp::Iq.new(:result, request.from.to_s)
          iq.id = request.id unless request.id.nil?
          iq.query = new
          Send(iq)
        end

        #.........................................................................................................
        def command_nodes(pipe, request)
          iq = Xmpp::Iq.new(:result, request.from.to_s)
          iq.id = request.id unless request.id.nil?
          iq.query = new
          iq.query.node = 'http://jabber.org/protocol/commands'
          iq.query.items = BaseController.command_nodes.map{|n| {:node => n, :name => n.humanize, :jid => pipe.jid.to_s}}
          Send(iq)
        end

      #### self
      end

      #.........................................................................................................
      def node
        attributes['node']
      end

      #.........................................................................................................
      def node=(val)
        attributes['node'] = val
      end

      #.........................................................................................................
      def set_node(val)
        self.node = val
        self
      end

      #.........................................................................................................
      def items
        get_elements('item')
      end

      #.........................................................................................................
      def items=(its)
        its.each{|i| self << DiscoItem.new(i[:jid], i[:name], i[:node])}
      end

    #### IqDiscoItems
    end

    #####-------------------------------------------------------------------------------------------------------
    class DiscoItem < Element

      #.........................................................................................................
      name_xmlns 'item', 'http://jabber.org/protocol/disco#items'

      #.........................................................................................................
      def initialize(jid=nil, iname=nil, node=nil)
        super()
        self.jid = jid
        self.iname = iname
        self.node = node
      end

      #.........................................................................................................
      def jid
        JID.new(attributes['jid'])
      end

      #.........................................................................................................
      def jid=(val)
        attributes['jid'] = val.to_s
      end

      def iname
        attributes['name']
      end

      #.........................................................................................................
      def iname=(val)
        attributes['name'] = val
      end

      #.........................................................................................................
      def node
        attributes['node']
      end

      #.........................................................................................................
      def node=(val)
        attributes['node'] = val
      end

    #### Item
    end
    
  #### Xmpp 
  end
  
#### AgentXmpp
end
