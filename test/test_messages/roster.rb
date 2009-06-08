##############################################################################################################
module Roster

  #####-------------------------------------------------------------------------------------------------------
  class << self
    
    #### received messages    
    #.........................................................................................................
    def recv_roster_success
      <<-MSG
        <iq from='dev@plan-b.ath.cx/troy-ubuntu' to='dev@plan-b.ath.cx/troy-ubuntu' id='3542' type='result'>
          <query xmlns='jabber:iq:roster'>
            <item subscription='both' jid='test@plan-b.ath.cx'/>
          </query>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_roster_failed
    end

    #.........................................................................................................
    def recv_contact_presence
      <<-MSG
        <presence from='test@plan-b.ath.cx/troy-ubuntu' to='dev@plan-b.ath.cx/troy-ubuntu'>
          <priority>1</priority>
        </presence>
      MSG
    end

    #.........................................................................................................
    def recv_subscription_request
    end

    #.........................................................................................................
    def recv_subscription_accept
    end

    #.........................................................................................................
    def recv_subscription_decline
    end

    #### sent messages    
    #.........................................................................................................
    def send_fetch_roster_request
      <<-MSG
        <iq id='3542' type='get' xmlns='jabber:client'>
          <query xmlns='jabber:iq:roster'/>
        </iq>
      MSG
     end

    #.........................................................................................................
    def send_subscription_request
    end

    #.........................................................................................................
    def send_subscription_accept
    end

    #.........................................................................................................
    def send_subscription_decline
    end
  
  end
      
end
