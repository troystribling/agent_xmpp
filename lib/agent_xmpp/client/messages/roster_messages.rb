##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  module RosterMessages

    def get_query_roster
      Resp(Jabber::Iq.new_rosterget) do |r|
        if r.type == :result and r.kind_of?(Jabber::Iq)
          [r.query.elements.collect{|i| broadcast_to_delegates(:did_receive_roster_item, self, i)}, \
            broadcast_to_delegates(:did_receive_all_roster_items, self)].smash
        elsif r.type.eql?(:error)
          raise AgentXmppError, "roster request failed"
        end
      end
    end

    #.........................................................................................................
    def set_query_roster(roster_item_jid)
      request = Jabber::Iq.new_rosterset
      request.query.add(Jabber::Roster::RosterItem.new(roster_item_jid))
      Resp(request) do |r|
        if r.type == :result and r.kind_of?(Jabber::Iq)
          [Resp(Jabber::Presence.new.set_type(:subscribe).set_to(roster_item_jid)), \
            broadcast_to_delegates(:did_acknowledge_add_roster_item, self, r, roster_item_jid)].smash
        elsif r.type.eql?(:error)
          AgentXmpp.logger.error "ERROR ADDING ROSTER ITEM: #{roster_item_jid}"
          broadcast_to_delegates(:did_receive_add_roster_item_error, self, r, roster_item_jid)
        end
      end
    end

    #.........................................................................................................
    def set_query_roster_remove(roster_item_jid)
      request = Jabber::Iq.new_rosterset
      request.query.add(Jabber::Roster::RosterItem.new(roster_item_jid, nil, :remove))
      Resp(request) do |r|
        if r.type == :result and r.kind_of?(Jabber::Iq)
          broadcast_to_delegates(:did_acknowledge_remove_roster_item, self, r, roster_item_jid)
        elsif r.type.eql?(:error)
          AgentXmpp.logger.error "ERROR REMOVING ROSTER ITEM: #{roster_item_jid}"
          broadcast_to_delegates(:did_receive_remove_roster_item_error, self, r, roster_item_jid)
        end
      end
    end
    
  #### RosterMessages
  end
  
#### AgentXmpp
end
