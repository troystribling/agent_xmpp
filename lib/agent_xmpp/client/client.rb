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
        AgentXmpp::Boot.call_restarting_server(self) if AgentXmpp::Boot.respond_to?(:call_restarting_server)
        sleep(10.0)
        AgentXmpp.logger.warn "RESTARTING SERVER"
      end
    end

    #.........................................................................................................
    def close_connection
      AgentXmpp.logger.info "CLOSE CONNECTION"
      connection.close_connection_after_writing unless connection.nil?
    end

    #.........................................................................................................
    def reconnect
      AgentXmpp.logger.info "RECONNECTING"
      connection.reconnect(jid.domain, port) unless connection.nil?
    end

    #.........................................................................................................
    def connected?
      connection and !connection.error?
    end

    #.........................................................................................................
    def add_delegate(delegate)
      connection.add_delegate(delegate) unless connection.nil?
    end

    #.........................................................................................................
    def remove_delegate(delegate)
      connection.remove_delegate(delegate)  unless connection.nil?
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
    def did_start_session(client_connection, stanza)
      AgentXmpp.logger.info "SESSION STARTED"
      client_connection.send_roster_request
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
        AgentXmpp.logger.info "RECEIVED PRESENCE FROM: #{from_jid}"
        client_connection.send_client_version_request(from_jid) \
          if not from_jid.eql?(client_connection.jid.to_s) and presence.type.nil?
      else
        AgentXmpp.logger.warn "RECEIVED PRESENCE FROM JID NOT IN ROSTER: #{from_jid}" 
        nil       
      end
    end

    #.........................................................................................................
    def did_receive_subscribe_request(client_connection, presence)
      from_jid = presence.from.to_s     
      if roster.has_key?(presence.from.bare.to_s ) 
        AgentXmpp.logger.info "RECEIVED SUBSCRIBE REQUEST: #{from_jid}"
        client_connection.accept_contact_request(from_jid)  
      else
        AgentXmpp.logger.warn "RECEIVED SUBSCRIBE REQUEST FROM JID NOT IN ROSTER: #{from_jid}"        
        client_connection.reject_contact_request(from_jid)  
      end
    end

    #.........................................................................................................
    def did_receive_unsubscribed_request(client_connection, presence)
      from_jid = presence.from.to_s     
      if roster.delete(presence.from.bare.to_s )           
        AgentXmpp.logger.info "RECEIVED UNSUBSCRIBED REQUEST: #{from_jid}"
        client_connection.remove_contact(presence.from)  
      else
        AgentXmpp.logger.warn "RECEIVED UNSUBSCRIBED REQUEST FROM JID NOT IN ROSTER: #{from_jid}"   
        nil     
      end
    end

    #.........................................................................................................
    def did_accept_subscription(client_connection, presence)
      from_jid = presence.from.to_s     
      AgentXmpp.logger.warn "SUBSCRIPTION ACCEPTED: #{from_jid}" 
      nil       
    end

    #.........................................................................................................
    # roster management
    #.........................................................................................................
    def did_receive_roster_item(client_connection, roster_item)
      AgentXmpp.logger.info "RECEIVED ROSTER ITEM"   
      roster_item_jid = roster_item.jid.to_s
      if roster.has_key?(roster_item_jid) 
        case roster_item.subscription   
        when :none
          if roster_item.ask.eql?(:subscribe)
            AgentXmpp.logger.info "CONTACT SUBSCRIPTION PENDING: #{roster_item_jid}"   
            roster[roster_item_jid][:status] = :ask 
          else
            AgentXmpp.logger.info "CONTACT ADDED TO ROSTER: #{roster_item_jid}"   
            roster[roster_item_jid][:status] = :added 
          end
        when :to
          AgentXmpp.logger.info "SUBSCRIBED TO CONTACT PRESENCE: #{roster_item_jid}"   
          roster[roster_item_jid][:status] = :to 
        when :from
          AgentXmpp.logger.info "CONTACT SUBSCRIBED TO PRESENCE: #{roster_item_jid}"   
          roster[roster_item_jid][:status] = :from 
        when :both    
          AgentXmpp.logger.info "CONTACT SUBSCRIPTION BIDIRECTIONAL: #{roster_item_jid}"   
          roster[roster_item_jid][:status] = :both 
          roster[roster_item_jid][:roster_item] = roster_item 
        end
        nil
      else
        AgentXmpp.logger.info "REMOVING ROSTER ITEM: #{roster_item_jid}"   
        client_connection.remove_roster_item(roster_item.jid)  
      end
    end

    #.........................................................................................................
    def did_remove_roster_item(client_connection, roster_item)
      AgentXmpp.logger.info "REMOVE ROSTER ITEM"   
      roster_item_jid = roster_item.jid.to_s
      if roster.has_key?(roster_item_jid) 
        AgentXmpp.logger.info "REMOVED ROSTER ITEM: #{roster_item_jid}"   
        roster.delete(roster_item_jid) 
      end
      nil
    end

    #.........................................................................................................
    def did_receive_all_roster_items(client_connection)
      AgentXmpp.logger.info "RECEIVED ALL ROSTER ITEMS"   
      roster.select{|j,r| r[:status].eql?(:inactive)}.collect do |j, r|
        AgentXmpp.logger.info "ADDING CONTACT: #{j}" 
        client_connection.add_roster_item(Jabber::JID.new(j))  
      end
    end

    #.........................................................................................................
    def did_acknowledge_add_roster_item(client_connection, response, roster_item_jid)
      AgentXmpp.logger.info "ADD ROSTER ITEM ACKNOWLEDGED: #{roster_item_jid.to_s}"
      nil
    end

    #.........................................................................................................
    def did_acknowledge_remove_roster_item(client_connection, response, roster_item_jid)
      AgentXmpp.logger.info "REMOVE ROSTER ITEM ACKNOWLEDGED: #{roster_item_jid.to_s}"
      nil
    end

    #.........................................................................................................
    def did_receive_remove_roster_item_error(client_connection, response, roster_item_jid)
      AgentXmpp.logger.info "REMOVE ROSTER ITEM RECEIVED ERROR: #{roster_item_jid.to_s}"
      nil
    end

    #.........................................................................................................
    def did_receive_add_roster_item_error(client_connection, response, roster_item_jid)
      AgentXmpp.logger.info "ADD ROSTER ITEM RECEIVED ERROR REMOVING: #{roster_item_jid.to_s}"
      roster.delete(roster_item_jid)
      nil
    end

    #.........................................................................................................
    # service discovery management
    #.........................................................................................................
    def did_receive_client_version_result(client_connection, from, version)
      if roster.has_key?(from.bare.to_s)
        AgentXmpp.logger.info "RECEIVED CLIENT VERSION RESULT: #{from.to_s}, #{version.iname}, #{version.version}"
        roster[from.bare.to_s][:resources][from.to_s][:version] = version
      else
        AgentXmpp.logger.warn "RECEIVED CLIENT VERSION RESULT FROM JID NOT IN ROSTER: #{from.to_s}"
      end        
      nil
    end

    #.........................................................................................................
    def did_receive_client_version_request(client_connection, request)
      if roster.has_key?(request.from.bare.to_s)
        AgentXmpp.logger.info "RECEIVED CLIENT VERSION REQUEST: #{request.from.to_s}"
        client_connection.send_client_version(request)
      else
        AgentXmpp.logger.warn "RECEIVED CLIENT VERSION REQUEST FROM JID NOT IN ROSTER: #{request.from.to_s}"
        nil
      end
    end

  #### Client
  end

#### AgentXmpp
end
