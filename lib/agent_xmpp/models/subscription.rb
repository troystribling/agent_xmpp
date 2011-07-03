##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class Subscription

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      def subscriptions(renew=false)
        @subscriptions ||= AgentXmpp.in_memory_db[:subscriptions]
      end

      #.........................................................................................................
      def drop
        AgentXmpp.in_memory_db(:subscriptions)
      end

      #.........................................................................................................
      def find_all
        subscriptions.all
      end

      #.........................................................................................................
      def update(msg, node, serv)
        case msg
          when AgentXmpp::Xmpp::Subscription then update_with_subscription(msg, node, serv)
          when AgentXmpp::Xmpp::Iq then update_with_subscription(msg.pubsub.subscription, node, serv)
        end                 
      end
 
      #.........................................................................................................
      def destroy_by_node(node)
        subscriptions.filter(:node => node).delete
      end 

      #.........................................................................................................
      def stats_by_node
        find_all.map do |s|
          node = s[:node].split('/')
          Message.stats_by_node(s[:node]).update(:node=>node.last, :jid=>"#{node[3]}@#{node[2]}")
        end
      end
      
      #.........................................................................................................
      # private
      #.........................................................................................................
      def update_with_subscription(msg, node, serv)
        begin
          subscriptions << {:node => node, :subscription => msg.subscription, :service => serv}
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
