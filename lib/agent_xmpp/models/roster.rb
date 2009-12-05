##############################################################################################################
module AgentXmpp
    
  #####-------------------------------------------------------------------------------------------------------
  class Roster

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      def roster(renew=false)
        @roster ||= AgentXmpp.in_memory_db[:roster]
      end

      #.........................................................................................................
      def update(msg, from=nil)
        case msg
          when AgentXmpp::Xmpp::Presence then update_with_presence(msg)
          when AgentXmpp::Xmpp::IqVersion then update_with_version(msg, from)
         end                 
      end
 
      #.........................................................................................................
      def update_status(jid, status)
        roster.filter(:jid => jid_to_s(jid)).update(:status => status.to_s)
      end
                
      #.........................................................................................................
      def find_all
        roster.all  
      end

      #.........................................................................................................
      def find_by_jid(jid)
        roster[:jid => jid_to_s(jid)]
      end 
      
      #.........................................................................................................
      def find_all_by_status(status)
        roster.filter(:status => status.to_s).all
      end

      #.........................................................................................................
      def find_all_by_contact_jid(jid)
        if contact = Contact.find_by_jid(jid)
          roster.filter(:contact_id => contact[:contact_id]).all
        else; []; end
      end 
      
      #.........................................................................................................
      def find_all_by_contact_jid_and_status(jid, status)
        if contact = Contact.find_by_jid(jid)
          roster.filter(:contact_id => contact[:id]).all
        else; []; end
      end 
      
      #.........................................................................................................
      def destroy_by_contact_id(contact_id)
        roster.filter(:contact_id => contact_id).delete
      end 

      #.........................................................................................................
      def has_version?(jid)
        if item = find_by_jid(jid)
          not (item[:client_name].nil? or item[:client_version].nil?)
        else; false; end
      end 

      #.........................................................................................................
      def method_missing(meth, *args, &blk)
        roster.send(meth, *args, &blk)
      end

      #.........................................................................................................
      # private
      #.........................................................................................................
      def update_with_presence(presence)
        from_jid = presence.from.to_s    
        contact = Contact.find_by_jid(presence.from)
        status = presence.type.nil? ? 'available' : presence.type.to_s 
        if (contact)
          begin
            roster << {:jid => from_jid, :status => status, :contact_id => contact[:id]}
          rescue 
            roster.filter(:jid => from_jid).update(:status => status)
          end
        end
      end

      #.........................................................................................................
      def update_with_version(vquery, from)
        if (item = roster.filter(:jid => from.to_s))  
          item.update(:client_name => vquery.iname, :client_version => vquery.version, :client_os => vquery.os)
        end
      end

      #.........................................................................................................
      def jid_to_s(jid)
        case jid
          when String then jid
          when Xmpp::Jid then jid.to_s
        else jid
        end 
      end  
      
      #.........................................................................................................
      private :update_with_presence, :update_with_version, :jid_to_s

    #### self
    end

  #### Roster
  end

#### AgentXmpp
end
