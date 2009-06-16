##############################################################################################################
module SystemDiscoveryMessages

  #####-------------------------------------------------------------------------------------------------------
  class << self
    
    #### received messages    
    #.........................................................................................................
    def recv_client_version_get(client, from)
      <<-MSG
        <iq from='#{from}' to='#{client.client.jid.to_s}' id='1' type='get'>
          <query xmlns='jabber:iq:version'/>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_client_version_result(client, from)
      <<-MSG
        <iq from='#{from}' to='#{client.client.jid.to_s}' id='1' type='result'>
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
    def send_client_version_result(client, to)
      <<-MSG
        <iq id='1' to='#{to}' type='result' xmlns='jabber:client'>
          <query xmlns='jabber:iq:version'>
            <name>#{AgentXmpp::AGENT_XMPP_NAME}</name>
            <version>#{AgentXmpp::VERSION}</version>
            <os>#{AgentXmpp::OS_VERSION}</os>
          </query>
        </iq>
      MSG
    end

    #.........................................................................................................
    def send_client_version_get(client, to)
      <<-MSG
        <iq id='1' to='#{to}' type='get' xmlns='jabber:client'>
          <query xmlns='jabber:iq:version'/>
        </iq>
      MSG
    end
    
  end

end
