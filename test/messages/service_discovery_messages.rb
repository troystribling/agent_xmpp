##############################################################################################################
module ServiceDiscoveryMessages

  #####-------------------------------------------------------------------------------------------------------
  class << self
    
    #### received messages    
    #.........................................................................................................
    def recv_iq_get_query_discoinfo(client, from)
      <<-MSG
        <iq from='#{from}' to='#{client.client.jid.to_s}' id='1' type='get' xmlns='jabber:client'>
          <query xmlns='http://jabber.org/protocol/disco#info'/>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_iq_get_query_discoinfo_error(client, from)
      <<-MSG
        <iq from='#{from}' to='#{client.client.jid.to_s}' id='1' type='get' xmlns='jabber:client'>
          <query node='http://jabber.org/protocol/nothing' xmlns='http://jabber.org/protocol/disco#info'/>
        </iq>
      MSG
    end


    #.........................................................................................................
    def recv_iq_get_query_discoitems(client, from)
      <<-MSG
        <iq from='#{from}' to='#{client.client.jid.to_s}' id='1' type='get' xmlns='jabber:client'>
          <query xmlns='http://jabber.org/protocol/disco#items'/>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_iq_get_query_discoitems_for_commands_node(client, from)
      <<-MSG
        <iq from='#{from}' to='#{client.client.jid.to_s}' id='1' type='get' xmlns='jabber:client'>
          <query node='http://jabber.org/protocol/commands' xmlns='http://jabber.org/protocol/disco#items'/>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_iq_get_query_discoitems_error(client, from)
      <<-MSG
        <iq from='#{from}' to='#{client.client.jid.to_s}' id='1' type='get' xmlns='jabber:client'>
          <query node='http://jabber.org/protocol/nothing' xmlns='http://jabber.org/protocol/disco#items'/>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_iq_result_query_discoinfo(client, from)
      <<-MSG
        <iq from='#{from}' to='#{client.client.jid.to_s}' id='2' type='result' xmlns='jabber:client'>
          <query xmlns='http://jabber.org/protocol/disco#info'>
            <identity name='Gajim' category='client' type='pc'/>
            <feature var='http://jabber.org/protocol/bytestreams'/>
            <feature var='http://jabber.org/protocol/si'/>
            <feature var='http://jabber.org/protocol/si/profile/file-transfer'/>
            <feature var='http://jabber.org/protocol/muc'/>
            <feature var='http://jabber.org/protocol/commands'/>
            <feature var='http://jabber.org/protocol/disco#info'/>
            <feature var='http://jabber.org/protocol/chatstates'/>
            <feature var='http://jabber.org/protocol/xhtml-im'/>
            <feature var='urn:xmpp:time'/>
          </query>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_iq_error_query_discoinfo(client, from)
      <<-MSG
        <iq from='#{from}' to='#{client.client.jid.to_s}' id='2' type='error' xmlns='jabber:client'>
        <query xmlns='http://jabber.org/protocol/disco#info'/>
        <error code='503' type='cancel'>
          <service-unavailable xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
        </error>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_iq_result_query_discoitems(client, from)
      <<-MSG
        <iq from='#{from}' to='#{client.client.jid.to_s}' id='1' type='result' xmlns='jabber:client'>
          <query xmlns='http://jabber.org/protocol/disco#items'>
            <item jid='conference.plan-b.ath.cx'/>
            <item jid='irc.plan-b.ath.cx'/>
            <item jid='proxy.plan-b.ath.cx'/>
            <item jid='pubsub.plan-b.ath.cx'/>
            <item jid='vjud.plan-b.ath.cx'/>
          </query>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_iq_error_query_discoitems(client, from)
      <<-MSG
        <iq from='#{from}' to='#{client.client.jid.to_s}' id='1' type='error' xmlns='jabber:client'>
        <query xmlns='http://jabber.org/protocol/disco#items'/>
        <error code='503' type='cancel'>
          <service-unavailable xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
        </error>
        </iq>
      MSG
    end

    #### sent messages    
    #.........................................................................................................
    def send_iq_get_query_discoinfo(client, to)
      <<-MSG
        <iq id='2' to='#{to}' type='get' xmlns='jabber:client'>
          <query xmlns='http://jabber.org/protocol/disco#info'/>
        </iq>
      MSG
    end
    
    #.........................................................................................................
    def send_iq_result_query_discoinfo(client, to)
      <<-MSG
        <iq id='1' to='#{to}' type='result' xmlns='jabber:client'>
          <query xmlns='http://jabber.org/protocol/disco#info'>
            <identity name='AgentXMPP' category='client' type='bot'/>
            <feature var='http://jabber.org/protocol/disco#info'/>
            <feature var='http://jabber.org/protocol/disco#items'/>
            <feature var='jabber:iq:version'/><feature var='jabber:x:data'/>
            <feature var='http://jabber.org/protocol/commands'/>
            <feature var='http://jabber.org/protocol/muc'/>
          </query>
        </iq>
      MSG
    end
    
    #.........................................................................................................
    def send_iq_error_discoinfo_service_unavailable(client, to)
      <<-MSG
        <iq id='1' to='#{to}' type='error' xmlns='jabber:client'>
          <query node='http://jabber.org/protocol/nothing' xmlns='http://jabber.org/protocol/disco#info'/>
          <error code='503' type='cancel'><service-unavailable xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
            <text xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'>service unavailable</text>
          </error>
        </iq>
      MSG
    end
   
    #.........................................................................................................
    def send_iq_get_query_discoitems(client, to)
      <<-MSG
        <iq id='1' to='#{to}' type='get' xmlns='jabber:client'>
          <query xmlns='http://jabber.org/protocol/disco#items'/>
        </iq>
      MSG
    end

    #.........................................................................................................
    def send_iq_result_query_discoitems(client, to)
      <<-MSG
        <iq id='1' to='#{to}' type='result' xmlns='jabber:client'>
          <query xmlns='http://jabber.org/protocol/disco#items'/>
        </iq>
      MSG
    end

    #.........................................................................................................
    def send_iq_error_discoitems_item_not_found(client, to)
      <<-MSG
        <iq id='1' to='#{to}' type='error' xmlns='jabber:client'>
          <query node='http://jabber.org/protocol/nothing' xmlns='http://jabber.org/protocol/disco#items'/>
          <error code='404' type='cancel'><item-not-found xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
            <text xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'>item not found</text>
          </error>
        </iq>
      MSG
    end
    
    #.........................................................................................................
    def send_iq_result_query_discoitems_for_commands_node(client, to)
      <<-MSG
        <iq id='1' to='#{to}' type='result' xmlns='jabber:client'>
          <query node='http://jabber.org/protocol/commands' xmlns='http://jabber.org/protocol/disco#items'>
            <item name='scalar' node='scalar' jid='#{client.client.jid.to_s}'/>
            <item name='hash' node='hash' jid='#{client.client.jid.to_s}'/>
            <item name='scalar array' node='scalar_array' jid='#{client.client.jid.to_s}'/>
            <item name='hash array' node='hash_array' jid='#{client.client.jid.to_s}'/>
            <item name='array hash' node='array_hash' jid='#{client.client.jid.to_s}'/>
            <item name='array hash array' node='array_hash_array' jid='#{client.client.jid.to_s}'/>
          </query>
        </iq>
      MSG
    end
    
  ## self  
  end

#### ServiceDiscoveryMessages
end
