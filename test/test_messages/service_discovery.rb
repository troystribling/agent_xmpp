##############################################################################################################
module ClientVersion

  #####-------------------------------------------------------------------------------------------------------
  class << self
    
    #### received messages    
    #.........................................................................................................
    def recv_client_version_request
      <<-MSG
        <iq from='test@plan-b.ath.cx/troy-ubuntu' to='dev@plan-b.ath.cx/troy-ubuntu' id='4942' type='get'>
          <query xmlns='jabber:iq:version'/>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_client_version
      <<-MSG
        <iq from='test@plan-b.ath.cx/troy-ubuntu' to='dev@plan-b.ath.cx/troy-ubuntu' id='4436' type='result'>
          <query xmlns='jabber:iq:version'>
            <name>AgentXMPP</name>
            <version>0.0.0</version>
            <os>Linux 2.6.27-14-generic</os>
          </query>
        </iq>
      MSG
    end

    #### sent messages    
    #.........................................................................................................
    def send_client_version
      <<-MSG
        <iq id='4942' to='test@plan-b.ath.cx/troy-ubuntu' type='result' xmlns='jabber:client'>
          <query xmlns='jabber:iq:version'>
            <name>#{AgentXmpp.AGENT_XMPP_NAME}</name>
            <version>#{AgentXmpp.VERSION}</version>
            <os>#{AgentXmpp.OS_VERSION}</os>
          </query>
        </iq>
      MSG
    end

    #.........................................................................................................
    def send_client_version_request
      <<-MSG
        <iq id='4436' to='test@plan-b.ath.cx/troy-ubuntu' type='get' xmlns='jabber:client'>
          <query xmlns='jabber:iq:version'/>
        </iq>
      MSG
    end
    
  end

end
