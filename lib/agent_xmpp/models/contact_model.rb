##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class ContactModel

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      def contacts
        @contacts ||= AgentXmpp.agent_xmpp_db[:contacts]
      end

      #.........................................................................................................
      def load_config
        if AgentXmpp.config['roster'].kind_of?(Array)
          AgentXmpp.config['roster'].each do |c|
            groups = c["groups"].kind_of?(Array) ? c["groups"].join(",") : []
            role = c["role"].nil? ? "user" : c["role"]
            begin
              contacts << {:jid => c["jid"], :groups => groups, :role => role, :status => "inactive"}
            rescue 
              contacts.filter(:jid => c["jid"]).update(:groups => groups, :role => role)
            end
          end
        end
      end

      #.........................................................................................................
      def update(roster_item)
        from_jid, subscription, ask = roster_item.jid.to_s, roster_item.subscription.to_s, roster_item.ask.to_s
        contacts.filter(:jid => from_jid).update(:subscription => subscription, :ask => ask)
      end

      #.........................................................................................................
      def update_status(jid, status)
        if contact = contacts.filter(:jid => jid.bare.to_s)
          contact.update(:status => status.to_s)
        end
      end

      #.........................................................................................................
      def find_by_jid(jid)
        contacts[:jid => jid.bare.to_s]
      end

      #.........................................................................................................
      def find_by_jid(jid)
        contacts[:jid => jid.bare.to_s]
      end

      #.........................................................................................................
      def find_all_by_status(status)
        contacts.filter(:status => status.to_s).all
      end

      #.........................................................................................................
      def has_jid?(jid)
        contacts.filter(:jid => jid.bare.to_s).count > 0
      end

      #.........................................................................................................
      def destroy_by_jid(jid)
        contact = contacts.filter(:jid => jid.bare.to_s)
        contact_id = contact.first[:contact_id]
        RosterModel.destroy_by_contact_id(contact_id)
        MessageModel.destroy_by_contact_id(contact_id)
        contact.delete
      end 

      #.........................................................................................................
      def method_missing(meth, *args, &blk)
        contacts.send(meth, *args, &blk)
      end

    #### self
    end

  #### ContactModel
  end

#### AgentXmpp
end
