##############################################################################################################
module ErrorMessages

  #####-------------------------------------------------------------------------------------------------------
  class << self
    
    #### received messages    
    #.........................................................................................................
    def recv_iq_error(client, from)
      <<-MSG
        <iq from='#{from}' to='#{client.client.jid.to_s}' id='1' type='get' xmlns='jabber:client'>
          <query node='http://jabber.org/protocol/nothing' xmlns='http://jabber.org/protocol/nothing'/>
        </iq>
      MSG
    end


    #### sent messages    
    #.........................................................................................................
    def send_iq_error(client, to)
      <<-MSG
        <iq id='1' to='#{to}' type='error' xmlns='jabber:client'>
          <error code='501' type='cancel'>
            <feature-not-implemented xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
            <text xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'>feature not implemented</text>
          </error>
        </iq>
      MSG
    end

  ## self  
  end

#### VersionDiscoveryMessages
end
