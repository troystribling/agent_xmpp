##############################################################################################################
module RosterMessages

  #####-------------------------------------------------------------------------------------------------------
  class << self
    
    #### received messages    
    #.........................................................................................................
    def recv_roster_result(client, roster_jids)
      subscriptions = roster_jids.inject("") {|s, r| s += "<item subscription='both' jid='#{r}'/>"}
      <<-MSG
        <iq from='#{client.client.jid.to_s}' to='#{client.client.jid.to_s}' id='1' type='result'>
          <query xmlns='jabber:iq:roster'>
            #{subscriptions}
          </query>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_roster_result_set_ack(client)
      "<iq from='#{client.client.jid.to_s}' to='#{client.client.jid.to_s}' id='1' type='result'/>"
    end

    #.........................................................................................................
    def recv_roster_set_none(client, roster_jid)
      <<-MSG
        <iq from='#{client.client.jid.to_s}' to='#{client.client.jid.to_s}' id='1' type='set'>
          <query xmlns='jabber:iq:roster'>
            <item subscription='none' jid='#{roster_jid}'/>
          </query>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_roster_set_subscribe_none(client, roster_jid)
      <<-MSG
        <iq from='#{client.client.jid.to_s}' to='#{client.client.jid.to_s}' id='push' type='set'>
          <query xmlns='jabber:iq:roster'>
            <item ask='subscribe' subscription='none' jid='#{roster_jid}'/>
          </query>
        </iq>
      MSG
     end

     #.........................................................................................................
     def recv_roster_set_to(client, roster_jid)
      <<-MSG
        <iq from='#{client.client.jid.to_s}' to='#{client.client.jid.to_s}' id='push' type='set'>
         <query xmlns='jabber:iq:roster'>
           <item subscription='to' jid='#{roster_jid}'/>
         </query>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_roster_set_both(client, roster_jid)
      <<-MSG
        <iq from='#{client.client.jid.to_s}' to='#{client.client.jid.to_s}' id='push' type='set'>
          <query xmlns='jabber:iq:roster'>
            <item subscription='both' jid='#{roster_jid}'/>
          </query>
        </iq>
      MSG
     end

    #.........................................................................................................
    def recv_presence_self(client)
      <<-MSG
        <presence from='#{client.client.jid.to_s}' to='#{client.client.jid.to_s}'>
          <priority>1</priority>
        </presence>
      MSG
    end

    #.........................................................................................................
    def recv_presence_available(client, from)
      <<-MSG
        <presence from='#{from}' to='#{client.client.jid.to_s}'>
          <priority>1</priority>
        </presence>
      MSG
    end

    #.........................................................................................................
    def recv_presence_unavailable(client, from)
      "<presence from='#{from}' to='#{client.client.jid.to_s}' type='unavailable'/>"
    end

    #.........................................................................................................
    def recv_presence_subscribe(client, from)
      "<presence from='#{from}' to='#{client.client.jid.to_s}' type='subscribe'/>"
    end

    #### sent messages    
    #.........................................................................................................
    def send_roster_get(client)
      <<-MSG
        <iq id='1' type='get' xmlns='jabber:client'>
          <query xmlns='jabber:iq:roster'/>
        </iq>
      MSG
     end

     #.........................................................................................................
     def send_roster_set(client, roster_jids)
       <<-MSG
        <iq id='1' type='set' xmlns='jabber:client'>
          <query xmlns='jabber:iq:roster'>
            <item jid='#{roster_jids}'/>
          </query>
        </iq>
       MSG
      end

     #.........................................................................................................
     def send_presence_subscribe(client, to)
       "<presence to='#{to}' type='subscribe' xmlns='jabber:client'/>"
     end
  
     #.........................................................................................................
     def send_presence_subscribed(client, to)
       "<presence to='#{to}' type='subscribed' xmlns='jabber:client'/>"
     end
  
  end
      
end
