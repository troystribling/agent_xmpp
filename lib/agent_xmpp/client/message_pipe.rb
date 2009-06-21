##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class MessagePipe

    #---------------------------------------------------------------------------------------------------------
    include SessionMessages
    include RosterMessages
    include PresenceMessages
    include ServiceDiscoveryMessages
    include ApplicationMessages
    #---------------------------------------------------------------------------------------------------------

    #---------------------------------------------------------------------------------------------------------
    attr_reader   :connection_status, :delegates, :id_callbacks, :client               
    attr_accessor :connection               
    #---------------------------------------------------------------------------------------------------------
    alias_method :send_to_method, :send
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize(client)
      @client = client
      @connection_status = :offline;
      @delegates = []
      @connection = nil
      @id_callbacks = {}
    end
    
    #.........................................................................................................
    def jid
      client.jid
    end

    #.........................................................................................................
    def password
      client.password
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
      raise AgentXmppError, 'not connected'  unless connected?
      if block_given? and data.kind_of?(Jabber::XMPPStanza)
        if data.id.nil?
          data.id = Jabber::IdGenerator.instance.generate_id
        end
        @id_callbacks[data.id] = blk
      end
      AgentXmpp.logger.info "SEND: #{data.to_s}"
      @connection.send_data(data.to_s)
    end

    #.........................................................................................................
    def send_resp(resp)
      resp.stuff_a.inject([]) do |m, r| 
        r.kind_of?(AgentXmpp::Response) ? m.push(send(r.message, &r.responds_with)) : m
      end
    end

    #.........................................................................................................
    def connected?
      connection and !connection.error?
    end
    
    #---------------------------------------------------------------------------------------------------------
    # process commands
    #.........................................................................................................
    def process_command(stanza)
      command = stanza.command
      params = {:xmlns => 'jabber:x:data', :action => command.action, :to => stanza.from.to_s, 
        :from => stanza.from.to_s, :node => command.node, :id => stanza.id, :fields => {}}
      AgentXmpp.logger.info "RECEIVED COMMAND NODE: #{command.node}, FROM: #{stanza.from.to_s}"
      Routing::Routes.invoke_command_response(self, params)
    end

    #---------------------------------------------------------------------------------------------------------
    # process messages
    #.........................................................................................................
    def process_chat_message_body(stanza)
      params = {:xmlns => 'message:chat', :to => stanza.from.to_s, :from => stanza.from.to_s, :id => stanza.id, \
        :body => stanza.body}
      AgentXmpp.logger.info "RECEIVED MESSAGE BODY: #{stanza.body}"
      Routing::Routes.invoke_chat_response(self, params)
    end

    #---------------------------------------------------------------------------------------------------------
    # connection callbacks
    #.........................................................................................................
    def receive(stanza)
      AgentXmpp.logger.info "RECV: #{stanza.to_s}"
      result = if stanza.kind_of?(Jabber::XMPPStanza) and stanza.id and blk = id_callbacks[stanza.id]
                 id_callbacks.delete(stanza.id)
                 blk.call(stanza)
               else
                 process_stanza(stanza)
               end
      send_resp(result)          
    end

    #.........................................................................................................
    def connection_completed
      AgentXmpp::Boot.call_if_implemented(:call_after_connected, self)     
      broadcast_to_delegates(:did_connect, self)
      init_connection(jid).collect{|m| send(m)}
    end

    #.........................................................................................................
    def unbind
      @connection_status = :off_line
      broadcast_to_delegates(:did_disconnect, self)
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
          authenticate(self)
        elsif connection_status.eql?(:authenticated)
          bind(stanza)
        end
      when 'stream'
      when 'success'
        if connection_status.eql?(:offline)
          @connection.reset_parser
          @connection_status = :authenticated
          broadcast_to_delegates(:did_authenticate, self, stanza)
          init_connection(jid, false)
        end
      when 'failure'
        if connection_status.eql?(:offline)
          @connection.reset_parser
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
        broadcast_to_delegates(:did_receive_subscribe, self, stanza)
      #### presence subscription accepted  
      elsif stanza.type.eql?(:subscribed) and stanza_class.eql?('Jabber::Presence')
        broadcast_to_delegates(:did_receive_subscribed, self, stanza)
      #### presence unsubscribe 
      elsif stanza.type.eql?(:unsubscribed) and stanza_class.eql?('Jabber::Presence')
        broadcast_to_delegates(:did_receive_unsubscribed, self, stanza)
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
  
  #### MessagePipe
  end

#### AgentXmpp
end
