##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class Connection < EventMachine::Connection

    #---------------------------------------------------------------------------------------------------------
    include Parser
    include SessionMessages
    include RosterMessages
    include PresenceMessages
    include ServiceDiscoveryMessages
    #---------------------------------------------------------------------------------------------------------

    #---------------------------------------------------------------------------------------------------------
    attr_reader :client, :jid, :port, :password, :connection_status, :delegates, :keepalive                
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize(client, jid, password, port=5222)
      @client, @jid, @password, @port = client, jid, password, port
      @connection_status = :offline;
      @id_callbacks = {}
      @delegates = []
    end
    
    #.........................................................................................................
    def add_delegate(delegate)
      @delegates << delegate
    end

    #.........................................................................................................
    def remove_delegate(delegate)
      @delegates.delete(delegate)
    end
    
    #.........................................................................................................
    def broadcast_to_delegates(method, *args)
      delegates.inject([]){|r,d| d.respond_to?(method) ? r.push(d.send(method, *args)) : r}.smash
    end
    
    #.........................................................................................................
    def send(data, &blk)
      raise AgentXmppError, 'not connected'  if error?
      if block_given? and data.is_a? Jabber::XMPPStanza
        if data.id.nil?
          data.id = Jabber::IdGenerator.instance.generate_id
        end
        @id_callbacks[data.id] = blk
      end
      AgentXmpp.logger.info "SEND: #{data.to_s}"
      send_data(data.to_s)
    end

    #---------------------------------------------------------------------------------------------------------
    # EventMachine::Connection callbacks
    #.........................................................................................................
    def connection_completed
      init_connection
      @keepalive = EventMachine::PeriodicTimer.new(60) do 
        send_data("\n")
      end
      add_delegate(client)      
      AgentXmpp::Boot.call_after_connection_completed(self) if AgentXmpp::Boot.respond_to?(:call_after_connection_completed)
      broadcast_to_delegates(:did_connect, self)
    end

    #.........................................................................................................
    def receive_data(data)
      AgentXmpp.logger.info "RECV: #{data.to_s}"
      super(data)
    end

    #.........................................................................................................
    def unbind
      if @keepalive
        @keepalive.cancel
        @keepalive = nil
      end
      @connection_status = :off_line
      broadcast_to_delegates(:did_disconnect, self)
    end

    #---------------------------------------------------------------------------------------------------------
    # process commands
    #.........................................................................................................
    def process_command(stanza)
      command = stanza.command
      unless command.x.nil? 
        params = {:xmlns => command.x.namespace, :action => command.action, :to => stanza.from.to_s, 
          :from => stanza.from.to_s, :node => command.node, :id => stanza.id, :fields => {}}
        AgentXmpp.logger.info "RECEIVED COMMAND: #{command.node}, FROM: #{stanza.from.to_s}"
        Routing::Routes.invoke_command_response(self, params)
      end
    end

    #---------------------------------------------------------------------------------------------------------
    # process messages
    #.........................................................................................................
    def process_chat_message_body(stanza)
      params = {:xmlns => 'message:chat', :to => stanza.from.to_s, :from => stanza.from.to_s, :id => stanza.id, 
        :body => stanza.body}
      AgentXmpp.logger.info "RECEIVED MESSAGE BODY: #{stanza.body}"
      Routing::Routes.invoke_chat_response(self, params)
    end

    #---------------------------------------------------------------------------------------------------------
    # AgentXmpp::Parser callbacks
    #.........................................................................................................
    def receive(stanza)
      if stanza.kind_of?(Jabber::XMPPStanza) and stanza.id and blk = @id_callbacks[stanza.id]
        @id_callbacks.delete(stanza.id)
        blk.call(stanza)
      else
        process_stanza(stanza)
      end           
    end

  #---------------------------------------------------------------------------------------------------------
  protected
  #---------------------------------------------------------------------------------------------------------
    
    #.........................................................................................................
    def process_stanza(stanza)
      case stanza.name
      when 'features'
        set_stream_features(stanza)
        if connection_status.eql?(:offline)
          authenticate
        elsif connection_status.eql?(:authenticated)
          bind(stanza)
        end
      when 'stream'
      when 'success'
        if connection_status.eql?(:offline)
          reset_parser
          @connection_status = :authenticated
          broadcast_to_delegates(:did_authenticate, self, stanza)
          init_connection(false)
        end
      when 'failure'
        if connection_status.eql?(:offline)
          reset_parser
          raise AgentXmppError, "authentication failed"
        end
      else
        demux_stanza(stanza)
      end
    end
    
    #.........................................................................................................
    def demux_stanza(stanza)
      stanza_class = stanza.class.to_s
      #### roster update
      if stanza.type == :set and stanza.query.kind_of?(Jabber::Roster::IqQueryRoster)
        [stanza.query.inject([]) do |r, i|  
          method =  i.subscription.eql?(:remove) ? :did_remove_roster_item : :did_receive_roster_item
          r.push(broadcast_to_delegates(method, self, i))
        end, broadcast_to_delegates(:did_receive_all_roster_items, self)].smash
      #### presence subscription request  
      elsif stanza.type.eql?(:subscribe) and stanza_class.eql?('Jabber::Presence')
        broadcast_to_delegates(:did_receive_subscribe_request, self, stanza)
      #### presence subscription accepted  
      elsif stanza.type.eql?(:subscribed) and stanza_class.eql?('Jabber::Presence')
        broadcast_to_delegates(:did_accept_subscription, self, stanza)
      #### presence unsubscribe 
      elsif stanza.type.eql?(:unsubscribed) and stanza_class.eql?('Jabber::Presence')
        broadcast_to_delegates(:did_receive_unsubscribed_request, self, stanza)
      #### client version request
      elsif stanza.type.eql?(:get) and stanza.query.kind_of?(Jabber::Version::IqQueryVersion)
        broadcast_to_delegates(:did_receive_client_version_request, self, stanza)
      #### received command
      elsif stanza.type.eql?(:set) and stanza.command.kind_of?(Jabber::Command::IqCommand)
        process_command(stanza)
      #### chat message received
      elsif stanza_class.eql?('Jabber::Message') and stanza.type.eql?(:chat) and stanza.respond_to?(:body)
        process_chat_message_body(stanza)
      else
        broadcast_to_delegates(('did_receive_' + /.*::(.*)/.match(stanza_class).to_a.last.downcase).to_sym, self, stanza)
      end
    end
  
  #### Connection
  end

#### AgentXmpp
end
