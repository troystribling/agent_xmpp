##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class SubscriptionModel

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      def subscription
        @subscription ||= AgentXmpp.in_memory_db[:subscription]
      end

      #.........................................................................................................
      def destroy_by_contact_id(jid)
        messages.filter(:contact_id => contact_id).delete
      end 

    #### self
    end

  #### ContactModel
  end

#### AgentXmpp
end