##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  module PresenceMessages

    #.........................................................................................................
    def presence_subscribed(contact_jid)
      presence = Jabber::Presence.new.set_type(:subscribed)
      presence.to = contact_jid  
      Send(presence)
    end

    #.........................................................................................................
    def presence_unsubscribed(contact_jid)
      presence = Jabber::Presence.new.set_type(:unsubscribed)
      presence.to = contact_jid      
      Send(presence)
    end
    
  #### RosterMessages
  end
  
#### AgentXmpp
end
