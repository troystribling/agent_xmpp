##############################################################################################################
module VersionDiscoveryMessages

  #####-------------------------------------------------------------------------------------------------------
  class << self
    
    #### received messages    
    #.........................................................................................................
    def recv_iq_get_query_version(client, from)
      <<-MSG
        <iq from='#{from}' to='#{client.client.jid.to_s}' id='1' type='get' xmlns='jabber:client'>
          <query xmlns='jabber:iq:version'/>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_iq_result_query_version(client, from)
      <<-MSG
        <iq from='#{from}' to='#{client.client.jid.to_s}' id='1' type='result' xmlns='jabber:client'>
          <query xmlns='jabber:iq:version'>
            <name>AgentXMPP</name>
            <version>0.0.0</version>
            <os>Linux 2.6.27-14-generic</os>
          </query>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_iq_error_query_version(client, from)
      <<-MSG
        <iq from='#{from}' to='#{client.client.jid.to_s}' id='1' type='error' xmlns='jabber:client'>
        <query xmlns='jabber:iq:version'/>
        <error code='503' type='cancel'>
          <service-unavailable xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
        </error>
        </iq>
      MSG
    end

    #### sent messages    
    #.........................................................................................................
    def send_iq_result_query_version(client, to)
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
    def send_iq_get_query_version(client, to)
      <<-MSG
        <iq id='1' to='#{to}' type='get' xmlns='jabber:client'>
          <query xmlns='jabber:iq:version'/>
        </iq>
      MSG
    end
    
  ## self  
  end

#### VersionDiscoveryMessages
end
