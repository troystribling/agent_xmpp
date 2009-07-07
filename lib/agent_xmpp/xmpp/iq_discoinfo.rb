# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class IqDiscoInfo < IqQuery

      #.........................................................................................................
      name_xmlns 'query', 'http://jabber.org/protocol/disco#info'

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
      def node
        attributes['node']
      end

      #.........................................................................................................
      def node=(val)
        attributes['node'] = val
      end

      #.........................................................................................................
      def identity
        first_element('identity')
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

      #.........................................................................................................
      def initialize(category=nil, iname=nil, type=nil)
        super()
        self.category = category
        self.iname = iname
        self.type = type
      end

      #.........................................................................................................
      def category
        attributes['category']
      end

      #.........................................................................................................
      def category=(val)
        attributes['category'] = val
      end

      #.........................................................................................................
      def iname
        attributes['name']
      end

      #.........................................................................................................
      def iname=(val)
        attributes['name'] = val
      end

      #.........................................................................................................
      def type
        attributes['type']
      end

      #.........................................................................................................
      def type=(val)
        attributes['type'] = val
      end
   
    #### DiscoIdentity 
    end

    #####-------------------------------------------------------------------------------------------------------
    class DiscoFeature < Element

      #.........................................................................................................
      name_xmlns 'feature', 'http://jabber.org/protocol/disco#info'

      #.........................................................................................................
      def initialize(var=nil)
        super()
        set_var(var)
      end

      #.........................................................................................................
      def var
        attributes['var']
      end

      #.........................................................................................................
      def var=(val)
        attributes['var'] = val
      end

      #.........................................................................................................
      def set_var(val)
        self.var = val
        self
      end
    
    #### DiscoFeature  
    end
    
  #### Xmpp
  end
  
#### AgentXmpp
end
