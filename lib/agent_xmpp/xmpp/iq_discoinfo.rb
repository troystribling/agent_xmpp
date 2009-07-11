# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class IqDiscoInfo < IqQuery

      #.........................................................................................................
      name_xmlns 'query', 'http://jabber.org/protocol/disco#info'
      xmpp_attribute :node

      #####-------------------------------------------------------------------------------------------------------
      class << self

        #.........................................................................................................
        def get(pipe, to=nil)
          iq = Iq.new(:get, to)
          query = IqDiscoInfo.new
          iq.add(query)
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
        get_elements('identity')
      end

      #.........................................................................................................
      def features
        elements.inject('feature', []) { |r, f| r.push(f.var)}
      end
  
      #.........................................................................................................
      def features=(feats)
        feats.each{|f| self << DiscoFeature.new(f)}
      end
  
    #### IqDiscoInfo
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
