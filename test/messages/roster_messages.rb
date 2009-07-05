##############################################################################################################
module RosterMessages

  #####-------------------------------------------------------------------------------------------------------
  class << self
    
    #### received messages    
    #.........................................................................................................
    def recv_iq_result_query_roster(client, roster_jids)
      subscriptions = roster_jids.inject("") {|s, r| s += "<item subscription='both' jid='#{r}'/>"}
      <<-MSG
        <iq from='#{client.client.jid.to_s}' to='#{client.client.jid.to_s}' id='3' type='result' xmlns='jabber:client'>
          <query xmlns='jabber:iq:roster'>
            #{subscriptions}
          </query>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_iq_result_query_roster_ack(client)
      "<iq from='#{client.client.jid.to_s}' to='#{client.client.jid.to_s}' id='5' type='result' xmlns='jabber:client'/>"
    end

    #.........................................................................................................
    def recv_error_query_roster_add(client)
      "<iq from='#{client.client.jid.to_s}' to='#{client.client.jid.to_s}' id='3' type='error' xmlns='jabber:client'/>"
    end

    #.........................................................................................................
    def recv_error_query_roster_remove(client)
      "<iq from='#{client.client.jid.to_s}' to='#{client.client.jid.to_s}' id='5' type='error' xmlns='jabber:client'/>"
    end

    #.........................................................................................................
    def recv_iq_set_query_roster_none(client, roster_jid)
      <<-MSG
        <iq from='#{client.client.jid.to_s}' to='#{client.client.jid.to_s}' id='1' type='set' xmlns='jabber:client'>
          <query xmlns='jabber:iq:roster'>
            <item subscription='none' jid='#{roster_jid}'/>
          </query>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_iq_set_query_roster_none_subscribe(client, roster_jid)
      <<-MSG
        <iq from='#{client.client.jid.to_s}' to='#{client.client.jid.to_s}' id='push' type='set' xmlns='jabber:client'>
          <query xmlns='jabber:iq:roster'>
            <item ask='subscribe' subscription='none' jid='#{roster_jid}'/>
          </query>
        </iq>
      MSG
     end

     #.........................................................................................................
     def recv_iq_set_query_roster_to(client, roster_jid)
      <<-MSG
        <iq from='#{client.client.jid.to_s}' to='#{client.client.jid.to_s}' id='push' type='set' xmlns='jabber:client'>
         <query xmlns='jabber:iq:roster'>
           <item subscription='to' jid='#{roster_jid}'/>
         </query>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_iq_set_query_roster_both(client, roster_jid)
      <<-MSG
        <iq from='#{client.client.jid.to_s}' to='#{client.client.jid.to_s}' id='push' type='set' xmlns='jabber:client'>
          <query xmlns='jabber:iq:roster'>
            <item subscription='both' jid='#{roster_jid}'/>
          </query>
        </iq>
      MSG
     end

     #.........................................................................................................
     def recv_iq_set_query_roster_remove(client, roster_jid)
       <<-MSG
         <iq from='#{client.client.jid.to_s}' to='#{client.client.jid.to_s}' id='push' type='set' xmlns='jabber:client'>
           <query xmlns='jabber:iq:roster'>
             <item jid='#{roster_jid}' subscription='remove'/>
           </query>
         </iq>
       MSG
      end

    #### sent messages    
    #.........................................................................................................
    def send_iq_get_query_roster(client)
      <<-MSG
        <iq id='3' type='get' xmlns='jabber:client'>
          <query xmlns='jabber:iq:roster'/>
        </iq>
      MSG
     end

     #.........................................................................................................
     def send_iq_set_query_roster(client, roster_jid)
       <<-MSG
        <iq id='5' type='set' xmlns='jabber:client'>
          <query xmlns='jabber:iq:roster'>
            <item jid='#{roster_jid}'/>
          </query>
        </iq>
       MSG
      end

      #.........................................................................................................
      def send_iq_set_query_roster_remove(client, roster_jid)
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
