##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class Subscription

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      def subscriptions
        @subscriptions ||= AgentXmpp.in_memory_db[:subscriptions]
      end

      #.........................................................................................................
      def update(msg, service)
        case msg
          when AgentXmpp::Xmpp::Subscription then update_with_subscription(msg, service)
          when AgentXmpp::Xmpp::Iq then update_with_subscription(msg.pubsub.subscription, service)
        end                 
      end
 
      #.........................................................................................................
      def destroy_by_node(node)
        subscriptions.filter(:node => node).delete
      end 

      #.........................................................................................................
      # private
      #.........................................................................................................
      def update_with_subscription(msg, service)
        begin
          subscriptions << {:node => msg.node, :subscription => msg.subscription, :service => service}
        rescue 
        end
      end
 
      #.........................................................................................................
      private :update_with_subscription

    #### self
    end

  #### Subscription
  end

#### AgentXmpp
end
