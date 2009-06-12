##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  module RosterMessages

    def send_roster_request
      send(Jabber::Iq.new_rosterget) do |r|
        if r.type == :result and r.query.kind_of?(Jabber::Roster::IqQueryRoster)
          [r.query.elements.collect {|i|  broadcast_to_delegates(:did_receive_roster_item, self, i)}, broadcast_to_delegates(:did_receive_all_roster_items, self)].flatten
        end
      end
    end

    #.........................................................................................................
    def add_contact(contact_jid)
      request = Jabber::Iq.new_rosterset
      request.query.add(Jabber::Roster::RosterItem.new(contact_jid))
      send(request) do |r|
        [send(Jabber::Presence.new.set_type(:subscribe).set_to(contact_jid)), broadcast_to_delegates(:did_acknowledge_add_contact, self, r, contact_jid)]
      end
    end

    #.........................................................................................................
    def remove_contact(contact_jid)
      request = Jabber::Iq.new_rosterset
      request.query.add(Jabber::Roster::RosterItem.new(contact_jid, nil, :remove))
      send(request) do |r|
        broadcast_to_delegates(:did_remove_contact, self, r, contact_jid)
      end
    end

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
