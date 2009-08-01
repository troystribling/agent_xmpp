# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class IqPubSub < Element

      #.......................................................................................................
      name_xmlns 'pubsub', 'http://jabber.org/protocol/pubsub'
      
      #####-------------------------------------------------------------------------------------------------------
      class << self

        #.........................................................................................................
        def create_node(pipe, to, node)
          iq = Xmpp::Iq.new(:set, to)  
          create = REXML::Element.new('create')
          create.add_attribute('node', node) 
          iq.pubsub = IqPubSub.new << create
          configure = REXML::Element.new('configure')
          user_config = AgentXmpp.published.find_by_node(node)
          if user_config
            form = Xmpp::XData.new(:submit)
            form.add_field_with_value('FORM_TYPE', 'http://jabber.org/protocol/pubsub#node_config', :hidden)
            configure << AgentXmpp::DEFAULT_PUBSUB_CONFIG.inject(form) do |f, (var, val)|             
              f.add_field_with_value("pubsub##{var.to_s}", user_config.send(var) || val)
            end
          end
          iq.pubsub << configure 
          Send(iq) do |r|
            if r.type == :result and r.kind_of?(Xmpp::Iq)
              pipe.broadcast_to_delegates(:did_receive_pubsub_create_node_result, pipe, r, node)
            elsif r.type.eql?(:error)
              pipe.broadcast_to_delegates(:did_receive_pubsub_create_node_error, pipe, r, node)
            end
          end     
        end

        #.........................................................................................................
        def subscriptions(pipe, to)
          iq = Xmpp::Iq.new(:get, to)
          iq.pubsub = IqPubSub.new << REXML::Element.new('subscriptions')
          Send(iq) do |r|
            if r.type == :result and r.kind_of?(Xmpp::Iq)
              pipe.broadcast_to_delegates(:did_receive_pubsub_subscriptions_result, pipe, r)
            elsif r.type.eql?(:error)
              pipe.broadcast_to_delegates(:did_receive_pubsub_subscriptions_error, pipe, r)
            end
          end     
        end

        #.........................................................................................................
        def subscribe(pipe, to, node)
          iq = Xmpp::Iq.new(:set, to)
          subscribe = REXML::Element.new('subscribe')
          subscribe.add_attribute('node', node) 
          subscribe.add_attribute('jid', AgentXmpp.jid.bare.to_s) 
          iq.pubsub = IqPubSub.new << subscribe
          Send(iq) do |r|
            if r.type == :result and r.kind_of?(Xmpp::Iq)
              pipe.broadcast_to_delegates(:did_receive_pubsub_subscribe_result, pipe, r, node)
            elsif r.type.eql?(:error)
              pipe.broadcast_to_delegates(:did_receive_pubsub_subscribe_error, pipe, r, node)
            end
          end     
        end

        #.........................................................................................................
        def unsubscribe(pipe, to, node)
          iq = Xmpp::Iq.new(:set, to)
          unsubscribe = REXML::Element.new('unsubscribe')
          unsubscribe.add_attribute('node', node) 
          unsubscribe.add_attribute('jid', AgentXmpp.jid.bare.to_s) 
          iq.pubsub = IqPubSub.new << unsubscribe
          Send(iq) do |r|
            if r.type == :result and r.kind_of?(Xmpp::Iq)
              pipe.broadcast_to_delegates(:did_receive_pubsub_unsubscribe_result, pipe, r, node)
            elsif r.type.eql?(:error)
              pipe.broadcast_to_delegates(:did_receive_pubsub_unsubscribe_error, pipe, r, node)
            end
          end     
        end

        #.........................................................................................................
        def affiliations(pipe, to)
          iq = Xmpp::Iq.new(:get, to)
          iq.pubsub = IqPubSub.new << REXML::Element.new('affiliations')
          Send(iq) do |r|
            if r.type == :result and r.kind_of?(Xmpp::Iq)
              pipe.broadcast_to_delegates(:did_receive_pubsub_affiliations_result, pipe, r)
            elsif r.type.eql?(:error)
              pipe.broadcast_to_delegates(:did_receive_pubsub_affiliations_error, pipe, r)
            end
          end     
        end

      #### self
      end
     
      #.........................................................................................................
      def subscriptions
        first_element('subscriptions').elements.to_a('subscription')
      end
     
    #### IqPubSub 
    end

    #####--------------------------------------------------------------------------------------------------------
    class IqPubSubOwner < Element

      #..........................................................................................................
      name_xmlns 'pubsub', 'http://jabber.org/protocol/pubsub' + '#owner'

      #####-------------------------------------------------------------------------------------------------------
      class << self

        #.........................................................................................................
        def delete_node(pipe, to, node)
          iq = Xmpp::Iq.new(:set, to)  
          delete = REXML::Element.new('delete')
          delete.add_attribute('node', node) 
          iq.pubsub = IqPubSubOwner.new << delete
          Send(iq) do |r|
            if r.type == :result and r.kind_of?(Xmpp::Iq)
              pipe.broadcast_to_delegates(:did_receive_pubsub_delete_node_result, pipe, r, node)
            elsif r.type.eql?(:error)
              pipe.broadcast_to_delegates(:did_receive_pubsub_delete_node_error, pipe, r, node)
            end
          end     
        end
      
      #### self
      end

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
          pub = IqPublish.new("#{pipe.user_pubsub_node}/#{args[:node]}") << item
          iq.pubsub = IqPubSub.new << pub
          Send(iq) do |r|
            if r.type == :result and r.kind_of?(Xmpp::Iq)
              pipe.broadcast_to_delegates(:did_receive_publish_result, pipe, r, args[:node])
            elsif r.type.eql?(:error)
              pipe.broadcast_to_delegates(:did_receive_publish_error, pipe, r, args[:node])
            end
          end     
        end

      #### self
      end

      #.........................................................................................................
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
    class Event < Element
      name_xmlns 'event', 'http://jabber.org/protocol/pubsub' + "#event"
      def items
        elements.to_a('items')
      end
   end

    #####-------------------------------------------------------------------------------------------------------
    class EventItems < Items
      name_xmlns 'items', 'http://jabber.org/protocol/pubsub' + "#event"
      #.........................................................................................................
      def item
        elements.to_a('item')
      end
    end

    #####-------------------------------------------------------------------------------------------------------
    class EventItem < Item
      name_xmlns 'item', 'http://jabber.org/protocol/pubsub' + "#event"
      xmpp_child :x
    end

    #####-------------------------------------------------------------------------------------------------------
    class Subscriptions < Element
      name_xmlns 'subscriptions', 'http://jabber.org/protocol/pubsub'
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
        (a = attribute('jid')).nil? ? a : Jid.new(a.value)
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
