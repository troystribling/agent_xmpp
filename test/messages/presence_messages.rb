##############################################################################################################
module PresenceMessages

  #####-------------------------------------------------------------------------------------------------------
  class << self
    
    #### received messages    
    #.........................................................................................................
    def recv_presence_self(client)
      <<-MSG
        <presence from='#{client.client.jid.to_s}' to='#{client.client.jid.to_s}' xmlns='jabber:client'>
          <priority>1</priority>
        </presence>
      MSG
    end

    #.........................................................................................................
    def recv_presence_available(client, from)
      <<-MSG
        <presence from='#{from}' to='#{client.client.jid.to_s}' xmlns='jabber:client'>
          <priority>1</priority>
        </presence>
      MSG
    end

    #.........................................................................................................
    def recv_presence_unavailable(client, from)
      "<presence from='#{from}' to='#{client.client.jid.to_s}' type='unavailable' xmlns='jabber:client'/>"
    end

    #.........................................................................................................
    def recv_presence_subscribe(client, from)
      "<presence from='#{from}' to='#{client.client.jid.to_s}' type='subscribe' xmlns='jabber:client'/>"
    end
 
    #.........................................................................................................
    def recv_presence_subscribed(client, from)
      "<presence from='#{from}' to='#{client.client.jid.to_s}' type='subscribed' xmlns='jabber:client'/>"
    end
    
    #.........................................................................................................
    def recv_presence_unsubscribed(client, from)
      "<presence from='#{from}' to='#{client.client.jid.to_s}' type='unsubscribed' xmlns='jabber:client'/>"
    end
        
    #### sent messages    
    #.........................................................................................................
    def send_presence_subscribe(client, to)
      "<presence to='#{to}' type='subscribe' xmlns='jabber:client'/>"
    end
 
    #.........................................................................................................
    def send_presence_subscribed(client, to)
      "<presence to='#{to}' type='subscribed' xmlns='jabber:client'/>"
    end
 
    #.........................................................................................................
    def send_presence_unsubscribed(client, to)
      "<presence to='#{to}' type='unsubscribed' xmlns='jabber:client'/>"
    end
   
  ## self  
  end
 
#### PresenceMessages      
end
