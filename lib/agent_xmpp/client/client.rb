##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class Client

    #---------------------------------------------------------------------------------------------------------
    attr_reader :jid, :port, :password, :roster, :connection
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize(config)
      @password = config['password']
      @port = config['port'] || 5222
      resource = config['resource'] || Socket.gethostname
      @jid = Jabber::JID.new("#{config['jid']}/#{resource}")
      @roster = Roster.new(@jid, config['contacts'])
    end

    #.........................................................................................................
    def connect
      while (true)
        EventMachine.run do
          @connection = EventMachine.connect(jid.domain, port, Connection, self, jid, password, port)
        end
        sleep(10.0)
        AgentXmpp.logger.warn "RESTARTING SERVER"
      end
    end

    #.........................................................................................................
    def reconnect
      AgentXmpp.logger.info "RECONNECTING"
      connection.reconnect(jid.domain, port)
    end

    #.........................................................................................................
    def connected?
      connection and !connection.error?
    end

    #.........................................................................................................
    def add_delegate(delegate)
      connection.add_delegate(delegate)
    end

    #.........................................................................................................
    def remove_delegate(delegate)
      connection.remove_delegate(delegate)
    end
    
    #---------------------------------------------------------------------------------------------------------
    # AgentXmpp::Connection delegate
    #.........................................................................................................
    # connection
    #.........................................................................................................
    def did_connect(client_connection)
      AgentXmpp.logger.info "CONNECTED"
    end

    #.........................................................................................................
    def did_disconnect(client_connection)
      AgentXmpp.logger.warn "DISCONNECTED"
      EventMachine::stop_event_loop
    end

    #.........................................................................................................
    def did_not_connect(client_connection)
      AgentXmpp.logger.warn "CONNECTION FAILED"
    end

    #.........................................................................................................
    # authentication
    #.........................................................................................................
    def did_authenticate(client_connection, stanza)
      AgentXmpp.logger.info "AUTHENTICATED"
    end
 
    #.........................................................................................................
    def did_not_authenticate(client_connection, stanza)
      AgentXmpp.logger.info "AUTHENTICATION FAILED"
    end

    #.........................................................................................................
    def did_bind(client_connection, stanza)
      AgentXmpp.logger.info "BIND ACKNOWLEDGED"
    end

    #.........................................................................................................
    # presence
    #.........................................................................................................
    def did_receive_presence(client_connection, presence)
      from_jid = presence.from.to_s     
      from_bare_jid = presence.from.bare.to_s     
      if roster.has_key?(from_bare_jid) 
        roster[from_bare_jid.to_s][:resources][from_jid] = {} if roster[from_bare_jid.to_s][:resources][from_jid].nil?
        roster[from_bare_jid.to_s][:resources][from_jid][:presence] = presence
        client_connection.get_client_version(from_jid) if not from_jid.eql?(client_connection.jid.to_s) and presence.type.nil?
        AgentXmpp.logger.info "RECEIVED PRESENCE FROM: #{from_jid}"
      else
        AgentXmpp.logger.info "RECEIVED PRESENCE FROM JID NOT IN CONTACT LIST: #{from_jid}"        
      end
    end

    #.........................................................................................................
    def did_receive_subscribe_request(client_connection, presence)
      from_jid = presence.from.to_s     
      if roster.has_key?(presence.from.bare.to_s ) 
        client_connection.accept_contact_request(from_jid)  
        AgentXmpp.logger.info "RECEIVED SUBSCRIBE REQUEST: #{from_jid}"
      else
        client_connection.reject_contact_request(from_jid)  
        AgentXmpp.logger.info "RECEIVED SUBSCRIBE REQUEST FROM JID NOT IN CONTACT LIST: #{from_jid}"        
      end
    end

    #.........................................................................................................
    def did_receive_unsubscribed_request(client_connection, presence)
      from_jid = presence.from.to_s     
      if roster.delete(presence.from.bare.to_s )           
        client_connection.remove_contact(presence.from)  
        AgentXmpp.logger.info "RECEIVED UNSUBSCRIBED REQUEST: #{from_jid}"
      else
        AgentXmpp.logger.warn "RECEIVED UNSUBSCRIBED REQUEST FROM JID NOT IN CONTACT LIST: #{from_jid}"        
      end
    end

    #.........................................................................................................
    # roster management
    #.........................................................................................................
    def did_receive_roster_item(client_connection, roster_item)
      AgentXmpp.logger.info "RECEIVED ROSTER ITEM"   
      roster_item_jid = roster_item.jid.to_s
      if roster.has_key?(roster_item_jid) 
        roster[roster_item_jid][:activated] = true 
        roster[roster_item_jid][:roster_item] = roster_item 
        AgentXmpp.logger.info "ACTIVATING CONTACT: #{roster_item_jid}"   
      else
        client_connection.remove_contact(roster_item.jid)  
        AgentXmpp.logger.info "REMOVING CONTACT: #{roster_item_jid}"   
      end
    end

    #.........................................................................................................
    def did_remove_roster_item(client_connection, roster_item)
      AgentXmpp.logger.info "REMOVE ROSTER ITEM"   
      roster_item_jid = roster_item.jid.to_s
      if roster.has_key?(roster_item_jid) 
        roster.delete(roster_item_jid) 
        AgentXmpp.logger.info "REMOVED CONTACT: #{roster_item_jid}"   
      end
    end

    #.........................................................................................................
    def did_receive_all_roster_items(client_connection)
      AgentXmpp.logger.info "RECEIVED ALL ROSTER ITEMS"   
      roster.select{|j,r| not r[:activated]}.each do |j,r|
        AgentXmpp.logger.info "ADDING CONTACT: #{j}" 
        client_connection.add_contact(Jabber::JID.new(j))  
      end
    end

    #.........................................................................................................
    def did_acknowledge_add_contact(client_connection, response, contact_jid)
      AgentXmpp.logger.info "CONTACT ADD ACKNOWLEDGED: #{contact_jid.to_s}"
    end

    #.........................................................................................................
    def did_remove_contact(client_connection, response, contact_jid)
      AgentXmpp.logger.info "CONTACT REMOVED: #{contact_jid.to_s}"
    end

    #.........................................................................................................
    def did_add_contact(client_connection, roster_item)
      AgentXmpp.logger.info "CONTACT ADDED: #{roster_item.jid.to_s}"
    end

    #.........................................................................................................
    # service discovery management
    #.........................................................................................................
    def did_receive_client_version_result(client_connection, from, version)
      roster[from.bare.to_s][:resources][from.to_s][:version] = version \
        unless roster[from.bare.to_s][:resources][from.to_s].nil?
      AgentXmpp.logger.info "RECEIVED CLIENT VERSION RESULT: #{from.to_s}, #{version.iname}, #{version.version}"
    end

    #.........................................................................................................
    def did_receive_client_version_request(client_connection, request)
      client_connection.send_client_version(request)
      AgentXmpp.logger.info "RECEIVED CLIENT VERSION REQUEST: #{request.from.to_s}"
    end

  #### Client
  end

#### AgentXmpp
end
