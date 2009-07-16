# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class IqPubSub < Element

      #.......................................................................................................
      name_xmlns 'pubsub', 'http://jabber.org/protocol/pubsub'
      xmpp_child :subscriptions      
      
      #####-------------------------------------------------------------------------------------------------------
      class << self

        #.........................................................................................................
        def create_user_node(pipe, pubsub)
          node = '/home/' + pipe.jid.domain + pipe.jid.node
          iq = Xmpp::Iq.new(:get, pubsub)  
          create = REXML::Element.new('create') 
          create.add_attribute('node', node)      
          iq.pubsub = IqPubSub.new << create
          pipe.send(iq) do |r|
            if r.type == :result and r.kind_of?(Xmpp::Iq)
              pipe.broadcast_to_delegates(:did_receive_create_user_node_result, pipe, r)
            elsif r.type.eql?(:error)
              pipe.broadcast_to_delegates(:did_receive_create_user_node_error, pipe, r)
            end
          end     
        end

        #.........................................................................................................
        def subscriptions_get(pipe, to)
          iq = Xmpp::Iq.new(:get, to)
          iq.pubsub = IqPubSub.new << REXML::Element.new('subscriptions')
          pipe.send(iq) do |r|
            if r.type == :result and r.kind_of?(Xmpp::Iq)
              pipe.broadcast_to_delegates(:did_receive_pusub_subscriptions_result, pipe, r)
            elsif r.type.eql?(:error)
              pipe.broadcast_to_delegates(:did_receive_pusub_subscriptions_error, pipe, r)
            end
          end     
        end

        #.........................................................................................................
        def affiliations_get(pipe, to)
          iq = Xmpp::Iq.new(:get, to)
          iq.pubsub = IqPubSub.new << REXML::Element.new('affiliations')
          pipe.send(iq) do |r|
            if r.type == :result and r.kind_of?(Xmpp::Iq)
              pipe.broadcast_to_delegates(:did_receive_pusub_affiliations_result, pipe, r)
            elsif r.type.eql?(:error)
              pipe.broadcast_to_delegates(:did_receive_pusub_affiliations_error, pipe, r)
            end
          end     
        end

      #### self
      end
     
    #### IqPubSub 
    end

    #####-------------------------------------------------------------------------------------------------------
    class IqPubSubOwner < Element
      name_xmlns 'pubsub', 'http://jabber.org/protocol/pubsub' + '#owner'
    end

    #####-------------------------------------------------------------------------------------------------------
    class IqPublish < Element

      #.........................................................................................................
      name_xmlns 'publish', 'http://jabber.org/protocol/pubsub'
      xmpp_attribute :node

      #####-------------------------------------------------------------------------------------------------------
      class << self

        #.........................................................................................................
        def set(pipe, args)
          iq = Xmpp::Iq.new(:set, args[:to])
          item =  Item.new << args[:payload]
          pub = IqPublish.new(args[:node]) << item
          iq.pubsub = IqPubSub.new << pub
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

      def initialize(node=nil)
        super()
        self.node = node if node
      end
    end

    #####-------------------------------------------------------------------------------------------------------
    class Items < Element
      name_xmlns 'items', 'http://jabber.org/protocol/pubsub'
      xmpp_attribute :node, :subid, :max_items
    end

    #####-------------------------------------------------------------------------------------------------------
    class Item < Element
      name_xmlns 'item', 'http://jabber.org/protocol/pubsub'
      xmpp_attribute :id
      def initialize(id=nil)
        super()
        self.id = id if id
      end
    end

    #####-------------------------------------------------------------------------------------------------------
    class EventItem < Item
      name_xmlns 'item', 'http://jabber.org/protocol/pubsub' + "#event"
    end

    #####-------------------------------------------------------------------------------------------------------
    class EventItems < Items
      name_xmlns 'items', 'http://jabber.org/protocol/pubsub' + "#event"
    end

    #####-------------------------------------------------------------------------------------------------------
    class Subscription < Element

      #.........................................................................................................
      name_xmlns 'subscription', 'http://jabber.org/protocol/pubsub'
      xmpp_attribute :node, :subid

      #.........................................................................................................
      def initialize(jid=nil, node=nil, subid=nil, subscription=nil) 
        super()
        self.jid = jid if jid
        self.node = node if node
        self.subid = subid if subid
        self.state = subscription if subscription
      end

      #.........................................................................................................
      def jid
        (a = attribute('jid')).nil? ? a : JID.new(a.value)
      end

      #.........................................................................................................
      def jid=(myjid)
        add_attribute('jid', myjid ? myjid.to_s : nil)
      end

      #.........................................................................................................
      def state
        sub = attributes['subscription']
        ['none', 'pending', 'subscribed', 'unconfigured'].include?(sub) ? sub.to_sym : nil
      end

      #.........................................................................................................
      def state=(mystate)
        attributes['subscription'] = mystate
      end
      alias subscription state

      #.........................................................................................................
      def need_approval?
        state == :pending
      end
      
    #### Subscription
    end
      
  #### Xmpp
  end

#### AgentXmpp
end
