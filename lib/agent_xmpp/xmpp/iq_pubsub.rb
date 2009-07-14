# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    module PubSub
      NS_PUBSUB = 'http://jabber.org/protocol/pubsub'

      #####-------------------------------------------------------------------------------------------------------
      class << self
      
        #.........................................................................................................
        def publish(pipe, args)
          iq = Xmpp::Iq.new(:set, args[:to])
          iq.id = args[:id] unless args[:id].nil?
          iq.pubsub = IqPubSub.new 
          item =  Item.new
          item << args[:payload]
          pub = IqPublish.new(args[:node])
          pub << item
          iq.pubsub << pub
          pipe.send(iq) do |r|
            if r.type == :result and r.kind_of?(Xmpp::Iq)
              pipe.broadcast_to_delegates(:did_acknowledge_publish, pipe, r, args[:node])
            elsif r.type.eql?(:error)
              AgentXmpp.logger.error "ERROR PUBLISHING NODE: #{args[:node]}"
              pipe.broadcast_to_delegates(:did_receive_publish_error, pipe, r, args[:node])
            end
          end     
        end

      #### self
      end

      #####-------------------------------------------------------------------------------------------------------
      class IqPubSub < Element
        name_xmlns 'pubsub', NS_PUBSUB
      end

      #####-------------------------------------------------------------------------------------------------------
      class IqPubSubOwner < Element
        name_xmlns 'pubsub', NS_PUBSUB + '#owner'
      end

      #####-------------------------------------------------------------------------------------------------------
      class IqPublish < Element
        name_xmlns 'publish', NS_PUBSUB
        xmpp_attribute :node
        def initialize(node=nil)
          super()
          self.node = node if node
        end
      end

      #####-------------------------------------------------------------------------------------------------------
      class Items < Element
        name_xmlns 'items', NS_PUBSUB
        xmpp_attribute :node, :subid, :max_items
      end

      #####-------------------------------------------------------------------------------------------------------
      class Item < Element
        name_xmlns 'item', NS_PUBSUB
        xmpp_attribute :id
        def initialize(id=nil)
          super()
          self.id = id if id
        end
      end

      #####-------------------------------------------------------------------------------------------------------
      class EventItem < Item
        name_xmlns 'item', NS_PUBSUB + "#event"
      end

      #####-------------------------------------------------------------------------------------------------------
      class EventItems < Items
        name_xmlns 'items', NS_PUBSUB + "#event"
      end

    #### PubSub
    end

  #### Xmpp
  end

#### AgentXmpp
end
