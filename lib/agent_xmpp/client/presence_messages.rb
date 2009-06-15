##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  module PresenceMessages

    #.........................................................................................................
    def accept_contact_request(contact_jid)
      presence = Jabber::Presence.new.set_type(:subscribed)
      presence.to = contact_jid  
      send(presence)
    end

    #.........................................................................................................
    def reject_contact_request(contact_jid)
      presence = Jabber::Presence.new.set_type(:unsubscribed)
      presence.to = contact_jid      
      send(presence)
    end
    
  #### RosterMessages
  end
  
#### AgentXmpp
end
