##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  module PresenceMessages

    #.........................................................................................................
    def subscribed_presence(contact_jid)
      presence = Jabber::Presence.new.set_type(:subscribed)
      presence.to = contact_jid  
      Resp(presence)
    end

    #.........................................................................................................
    def unsubscribed_presence(contact_jid)
      presence = Jabber::Presence.new.set_type(:unsubscribed)
      presence.to = contact_jid      
      Resp(presence)
    end
    
  #### RosterMessages
  end
  
#### AgentXmpp
end
