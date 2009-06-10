##############################################################################################################
module RosterMessages

  #####-------------------------------------------------------------------------------------------------------
  class << self
    
    #### received messages    
    #.........................................................................................................
    def recv_roster_success(client)
      <<-MSG
        <iq from='dev@plan-b.ath.cx/troy-ubuntu' to='dev@plan-b.ath.cx/troy-ubuntu' id='3542' type='result'>
          <query xmlns='jabber:iq:roster'>
            <item subscription='both' jid='test@plan-b.ath.cx'/>
          </query>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_roster_failed(client)
    end

    #.........................................................................................................
    def recv_contact_presence(client)
      <<-MSG
        <presence from='test@plan-b.ath.cx/troy-ubuntu' to='dev@plan-b.ath.cx/troy-ubuntu'>
          <priority>1</priority>
        </presence>
      MSG
    end

    #.........................................................................................................
    def recv_subscription_request(client)
    end

    #.........................................................................................................
    def recv_subscription_accept(client)
    end

    #.........................................................................................................
    def recv_subscription_decline(client)
    end

    #### sent messages    
    #.........................................................................................................
    def send_get_roster_request(client)
      <<-MSG
        <iq id='1' type='get' xmlns='jabber:client'>
          <query xmlns='jabber:iq:roster'/>
        </iq>
      MSG
     end

    #.........................................................................................................
    def send_subscription_request(client)
    end

    #.........................................................................................................
    def send_subscription_accept(client)
    end

    #.........................................................................................................
    def send_subscription_decline(client)
    end
  
  end
      
end
