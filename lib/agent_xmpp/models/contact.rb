##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class Contact

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      def contacts
        @contacts ||= AgentXmpp.agent_xmpp_db[:contacts]
      end

      #.........................................................................................................
      def load_config
        if AgentXmpp.config['roster'].kind_of?(Array)
          AgentXmpp.config['roster'].each {|c| update(c)}
        end
      end

      #.........................................................................................................
      def update(contact)
        groups = contact['groups'].kind_of?(Array) ? contact['groups'].join(",") : contact['groups']
        begin
          contacts << {:jid => contact['jid'], :groups => groups, :subscription => 'new', :ask => 'new'}
        rescue 
          contacts.filter(:jid => contact['jid']).update(:groups => groups)
        end
      end

      #.........................................................................................................
      def update_with_roster_item(roster_item)
        from_jid, subscription, ask = roster_item.jid.to_s, roster_item.subscription.to_s, roster_item.ask.to_s
        contacts.filter(:jid => from_jid).update(:subscription => subscription, :ask => ask)
      end

      #.........................................................................................................
      def find_all
        contacts.all
      end

      #.........................................................................................................
      def find_by_jid(jid)
        contacts[:jid => jid_to_s(jid)]
      end

      #.........................................................................................................
      def find_all_by_subscription(subscription)
        contacts.filter(:subscription => subscription.to_s).all
      end

      #.........................................................................................................
      def has_jid?(jid)
        contacts.filter(:jid => jid_to_s(jid)).count > 0
      end

      #.........................................................................................................
      def destroy_by_jid(jid)
        contact = contacts.filter(:jid => jid_to_s(jid))
        contact_id = contact.first[:contact_id]
        Roster.destroy_by_contact_id(contact_id)
        contact.delete
      end 

      #.........................................................................................................
      def method_missing(meth, *args, &blk)
        contacts.send(meth, *args, &blk)
      end

      #.........................................................................................................
      # private
      #.........................................................................................................
      def jid_to_s(jid)
        case jid
          when String then Xmpp::Jid.new(jid).bare.to_s
          when Xmpp::Jid then jid.bare.to_s
        else jid
        end 
      end  

      #.........................................................................................................
      private :jid_to_s
      
    #### self
    end

  #### Contact
  end

#### AgentXmpp
end
