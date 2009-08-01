# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class IqDiscoItems < IqQuery

      #.........................................................................................................
      name_xmlns 'query', 'http://jabber.org/protocol/disco#items'
      xmpp_attribute :node

      #####-----------------------------------------------------------------------------------------------------
      class << self

        #.........................................................................................................
        def get(pipe, to=nil, node=nil)
          iq = Iq.new(:get, to)
          iq.query = new
          iq.query.node = node if node
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
        def result_command_nodes(pipe, request)
          iq = Xmpp::Iq.new(:result, request.from.to_s)
          iq.id = request.id unless request.id.nil?
          iq.query = new
          iq.query.node = 'http://jabber.org/protocol/commands'
          iq.query.items = BaseController.command_nodes.map{|n| {:node => n, :name => n.humanize, :jid => AgentXmpp.jid.to_s}}
          Send(iq)
        end

      #### self
      end

      #.........................................................................................................
      def items
        elements.to_a('item')
      end

      #.........................................................................................................
      def items=(its)
        its.each{|i| self << DiscoItem.new(i[:jid], i[:name], i[:node])}
      end

    #### IqDiscoItems
    end

    #####-------------------------------------------------------------------------------------------------------
    class IqDiscoInfo < IqQuery

      #.........................................................................................................
      name_xmlns 'query', 'http://jabber.org/protocol/disco#info'
      xmpp_attribute :node

      #####-------------------------------------------------------------------------------------------------------
      class << self

        #.........................................................................................................
        def get(pipe, to=nil, node=nil)
          iq = Iq.new(:get, to)
          iq.query = new
          iq.query.node = node if node
          Send(iq) do |r|
            if (r.type == :result) && r.query.kind_of?(Xmpp::IqDiscoInfo)
              pipe.broadcast_to_delegates(:did_receive_discoinfo_result, pipe, r)
            elsif r.type.eql?(:error)
              pipe.broadcast_to_delegates(:did_receive_discoinfo_error, pipe, r)
            end
          end
        end
        
        #.........................................................................................................
        def result(pipe, request)
          iq = Xmpp::Iq.new(:result, request.from.to_s)
          iq.id = request.id unless request.id.nil?
          iq.query = IqDiscoInfo.new
          iq.query << DiscoIdentity.new(AgentXmpp::IDENTITY[:category], AgentXmpp::IDENTITY[:name], AgentXmpp::IDENTITY[:type])
          iq.query.features = AgentXmpp::FEATURES
          Send(iq)
        end
        
      #### self  
      end
      
      #.........................................................................................................
      def identities
        elements.to_a('identity')
      end

      #.........................................................................................................
      def features
        elements.to_a('feature')
      end
  
      #.........................................................................................................
      def features=(feats)
        feats.each{|f| self << DiscoFeature.new(f)}
      end
  
    #### IqDiscoInfo
    end

    #####-------------------------------------------------------------------------------------------------------
    class DiscoItem < Element

      #.........................................................................................................
      name_xmlns 'item', 'http://jabber.org/protocol/disco#items'
      xmpp_attribute :node

      #.........................................................................................................
      def initialize(jid=nil, iname=nil, node=nil)
        super()
        self.jid = jid if jid
        self.iname = iname if iname
        self.node = node if node
      end

      #.........................................................................................................
      def jid
        Jid.new(attributes['jid'])
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

    #### DiscoItem
    end

    #####-------------------------------------------------------------------------------------------------------
    class DiscoIdentity < Element

      #.........................................................................................................
      name_xmlns 'identity', 'http://jabber.org/protocol/disco#info'
      xmpp_attribute :node, :category, :type

      #.........................................................................................................
      def initialize(category=nil, iname=nil, type=nil)
        super()
        self.category = category if category
        self.iname = iname if iname
        self.type = type if type
      end

      def iname
        attributes['name']
      end

      #.........................................................................................................
      def iname=(val)
        attributes['name'] = val
      end

    #### DiscoIdentity 
    end

    #####-------------------------------------------------------------------------------------------------------
    class DiscoFeature < Element

      #.........................................................................................................
      name_xmlns 'feature', 'http://jabber.org/protocol/disco#info'
      xmpp_attribute :var

      #.........................................................................................................
      def initialize(var=nil)
        super()
        self.var = var
      end

    #### DiscoFeature  
    end
    
  #### Xmpp
  end
  
#### AgentXmpp
end
