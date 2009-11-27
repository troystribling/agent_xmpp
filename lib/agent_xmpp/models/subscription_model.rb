##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class SubscriptionModel

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      def subscriptions
        @subscriptions ||= AgentXmpp.in_memory_db[:subscriptions]
      end

      #.........................................................................................................
      def update(msg, service)
        begin
          subscriptions << {:node => msg.node, :subscription => msg.subscription, :service => service}
        rescue 
        end
      end
 
      #.........................................................................................................
      def update_message_count(nodes)
        subs = subscriptions.filter(:node => node)
        subs.update(:message_count => pubs.first[:message_count]+1)
      end

    #### self
    end

  #### ContactModel
  end

#### AgentXmpp
end
