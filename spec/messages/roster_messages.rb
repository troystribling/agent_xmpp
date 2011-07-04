##############################################################################################################
module RosterMessages

  #####-------------------------------------------------------------------------------------------------------
  class << self
    
    #### received messages    
    #.........................................................................................................
    def recv_iq_result_query_roster(jid, roster_jids)
      subscriptions = roster_jids.inject("") {|s, r| s += "<item subscription='both' jid='#{r}'/>"}
      <<-MSG
        <iq from='#{jid.to_s}' to='#{jid.to_s}' id='1' type='result' xmlns='jabber:client'>
          <query xmlns='jabber:iq:roster'>
            #{subscriptions}
          </query>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_iq_result_query_roster_ack(jid)
      "<iq from='#{jid.bare}' to='#{jid.to_s}' id='1' type='result' xmlns='jabber:client'/>"
    end

    #.........................................................................................................
    def recv_error_query_roster_add(jid)
      "<iq from='#{jid.bare}' to='#{jid.to_s}' id='1' type='error' xmlns='jabber:client'/>"
    end

    #.........................................................................................................
    def recv_error_query_roster_remove(jid)
      "<iq from='#{jid.bare}' to='#{jid.to_s}' id='1' type='error' xmlns='jabber:client'/>"
    end

    #.........................................................................................................
    def recv_iq_set_query_roster_none(jid, roster_jid)
      <<-MSG
        <iq from='#{jid.bare}' to='#{jid.to_s}' id='1' type='set' xmlns='jabber:client'>
          <query xmlns='jabber:iq:roster'>
            <item subscription='none' jid='#{roster_jid}'/>
          </query>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_iq_set_query_roster_none_subscribe(jid, roster_jid)
      <<-MSG
        <iq from='#{jid.bare}' to='#{jid.to_s}' id='1' type='set' xmlns='jabber:client'>
          <query xmlns='jabber:iq:roster'>
            <item ask='subscribe' subscription='none' jid='#{roster_jid}'/>
          </query>
        </iq>
      MSG
     end

     #.........................................................................................................
     def recv_iq_set_query_roster_to(jid, roster_jid)
      <<-MSG
        <iq from='#{jid.bare}' to='#{jid.to_s}' id='1' type='set' xmlns='jabber:client'>
         <query xmlns='jabber:iq:roster'>
           <item subscription='to' jid='#{roster_jid}'/>
         </query>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_iq_set_query_roster_both(jid, roster_jid)
      <<-MSG
        <iq from='#{jid.bare}' to='#{jid.to_s}' id='1' type='set' xmlns='jabber:client'>
          <query xmlns='jabber:iq:roster'>
            <item subscription='both' jid='#{roster_jid}'/>
          </query>
        </iq>
      MSG
     end

     #.........................................................................................................
     def recv_iq_set_query_roster_remove(jid, roster_jid)
       <<-MSG
         <iq from='#{jid.bare}' to='#{jid.to_s}' id='1' type='set' xmlns='jabber:client'>
           <query xmlns='jabber:iq:roster'>
             <item jid='#{roster_jid}' subscription='remove'/>
           </query>
         </iq>
       MSG
      end

    #### sent messages    
    #.........................................................................................................
    def send_iq_get_query_roster(jid)
      <<-MSG
        <iq id='1' type='get' xmlns='jabber:client'>
          <query xmlns='jabber:iq:roster'/>
        </iq>
      MSG
     end

     #.........................................................................................................
     def send_iq_set_query_roster(jid, roster_jid)
       <<-MSG
        <iq id='5' type='set' xmlns='jabber:client'>
          <query xmlns='jabber:iq:roster'>
            <item jid='#{roster_jid}'/>
          </query>
        </iq>
       MSG
      end

      #.........................................................................................................
      def send_iq_set_query_roster_remove(jid, roster_jid)
        <<-MSG
         <iq id='5' type='set' xmlns='jabber:client'>
           <query xmlns='jabber:iq:roster'>
             <item jid='#{roster_jid}' subscription='remove'/>
           </query>
         </iq>
        MSG
       end

  ## self  
  end
  
#### RosterMessages      
end
