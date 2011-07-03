##############################################################################################################
module PresenceMessages

  #####-------------------------------------------------------------------------------------------------------
  class << self
    
    #### received messages    
    #.........................................................................................................
    def recv_presence_self(jid)
      <<-MSG
        <presence from='#{jid.to_s}' to='#{client.client.jid.to_s}' xmlns='jabber:client'>
          <priority>1</priority>
        </presence>
      MSG
    end

    #.........................................................................................................
    def recv_presence_available(jid, from)
      <<-MSG
        <presence from='#{from.to_s}' to='#{jid.to_s}' xmlns='jabber:client'>
          <priority>1</priority>
        </presence>
      MSG
    end

    #.........................................................................................................
    def recv_presence_unavailable(jid, from)
      "<presence from='#{from.to_s}' to='#{jid.to_s}' type='unavailable' xmlns='jabber:client'/>"
    end

    #.........................................................................................................
    def recv_presence_subscribe(jid, from)
      "<presence from='#{from.to_s}' to='#{jid.to_s}' type='subscribe' xmlns='jabber:client'/>"
    end
 
    #.........................................................................................................
    def recv_presence_subscribed(jid, from)
      "<presence from='#{from.to_s}' to='#{jid.to_s}' type='subscribed' xmlns='jabber:client'/>"
    end
    
    #.........................................................................................................
    def recv_presence_unsubscribed(jid, from)
      "<presence from='#{from.to_s}' to='#{jid.to_s}' type='unsubscribed' xmlns='jabber:client'/>"
    end
        
    #### sent messages  
    #.........................................................................................................
    def send_sign_on_presence(jid)
      <<-MSG
        <presence xmlns='jabber:client'>
          <priority>1</priority>
        </presence>
      MSG
    end
      
    #.........................................................................................................
    def send_presence_subscribe(jid, to)
      "<presence to='#{to.to_s}' type='subscribe' xmlns='jabber:client'/>"
    end
 
    #.........................................................................................................
    def send_presence_subscribed(jid, to)
      "<presence to='#{to.to_s}' type='subscribed' xmlns='jabber:client'/>"
    end
 
    #.........................................................................................................
    def send_presence_unsubscribed(jid, to)
      "<presence to='#{to.to_s}' type='unsubscribed' xmlns='jabber:client'/>"
    end
   
  ## self  
  end
 
#### PresenceMessages      
end
