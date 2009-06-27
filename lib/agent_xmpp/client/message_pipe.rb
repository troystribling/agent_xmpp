##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class MessagePipe

    #---------------------------------------------------------------------------------------------------------
    attr_reader   :connection_status, :delegates, :id_callbacks, :client, :stream_features, \
                  :stream_mechanisms, :roster            
    attr_accessor :connection               
    #---------------------------------------------------------------------------------------------------------
    alias_method :send_to_method, :send
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize(client, config)
      @client = client
      @connection_status = :offline;
      @delegates = [self.class]
      @connection = nil
      @id_callbacks = {}
      @roster = RosterModel.new(client.jid, config['contacts'])
    end
    
    #.........................................................................................................
    def jid
      client.jid
    end

    #.........................................................................................................
    def jid=(jid)
      client.jid = jid
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
      if block_given? and data.kind_of?(Xmpp::Stanza)
        if data.id.nil?
          data.id = Xmpp::IdGenerator.generate_id
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
      Controller.new(self, params).invoke_command
    end

    #---------------------------------------------------------------------------------------------------------
    # process chat messages
    #.........................................................................................................
    def process_chat_message_body(stanza)
      params = {:xmlns => 'message:chat', :to => stanza.from.to_s, :from => stanza.from.to_s, :id => stanza.id, \
        :body => stanza.body}
      AgentXmpp.logger.info "RECEIVED MESSAGE BODY: #{stanza.body}"
      Controller.new(self, params).invoke_chat
    end

    #---------------------------------------------------------------------------------------------------------
    # connection callbacks
    #.........................................................................................................
    def receive(stanza)
      AgentXmpp.logger.info "RECV: #{stanza.to_s}"
      result = if stanza.kind_of?(Xmpp::Stanza) and stanza.id and blk = id_callbacks[stanza.id]
                 id_callbacks.delete(stanza.id)
                 blk.call(stanza)
               else
                 process_stanza(stanza)
               end
      send_resp(result)          
    end

    #.........................................................................................................
    def connection_completed
      Boot.call_if_implemented(:call_after_connected, self)     
      broadcast_to_delegates(:did_connect, self)
      init_connection(jid).collect{|m| send(m)}
    end

    #.........................................................................................................
    def unbind
      @connection_status = :off_line
      broadcast_to_delegates(:did_disconnect, self)
    end
    
  private

    #.........................................................................................................
    def process_stanza(stanza)
      case stanza.name
      when 'features'
        set_stream_features_and_mechanisms(stanza)
        if connection_status.eql?(:offline)
          Xmpp::SASL.authenticate(stream_mechanisms, self)
        elsif connection_status.eql?(:authenticated)
          Xmpp::Iq.bind(stanza, self) if stream_features.has_key?('bind') and stream_features.has_key?('session')
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
      if stanza.type == :set and stanza.query.kind_of?(AgentXmpp::Xmpp::IqRoster)
        [stanza.query.inject([]) do |r, i|  
          method =  i.subscription.eql?(:remove) ? :did_remove_roster_item : :did_receive_roster_item
          r.push(broadcast_to_delegates(method, self, i))
        end, broadcast_to_delegates(:did_receive_all_roster_items, self)].smash
      #### presence subscription request  
      elsif stanza.type.eql?(:subscribe) and stanza_class.eql?('AgentXmpp::Xmpp::Presence')
        broadcast_to_delegates(:did_receive_presence_subscribe, self, stanza)
      #### presence subscription accepted  
      elsif stanza.type.eql?(:subscribed) and stanza_class.eql?('AgentXmpp::Xmpp::Presence')
        broadcast_to_delegates(:did_receive_presence_subscribed, self, stanza)
      #### presence unsubscribe 
      elsif stanza.type.eql?(:unsubscribed) and stanza_class.eql?('AgentXmpp::Xmpp::Presence')
        broadcast_to_delegates(:did_receive_presence_unsubscribed, self, stanza)
      #### client version request
      elsif stanza.type.eql?(:get) and stanza.query.kind_of?(AgentXmpp::Xmpp::IqVersion)
        broadcast_to_delegates(:did_receive_client_version_get, self, stanza)
      #### received command
      elsif stanza.type.eql?(:set) and stanza.command.kind_of?(AgentXmpp::Xmpp::IqCommand)
        process_command(stanza)
      #### chat message received
      elsif stanza_class.eql?('AgentXmpp::Xmpp::Message') and stanza.type.eql?(:chat) and stanza.respond_to?(:body)
        process_chat_message_body(stanza)
      else
        broadcast_to_delegates(('did_receive_' + /.*::(.*)/.match(stanza_class).to_a.last.downcase).to_sym, self, stanza)
      end
    end
  
    #.........................................................................................................
    def set_stream_features_and_mechanisms(stanza)
      @stream_features, @stream_mechanisms = {}, []
      stanza.elements.each do |e|
        if e.name == 'mechanisms' and e.namespace == 'urn:ietf:params:xml:ns:xmpp-sasl'
          e.each_element('mechanism') {|mech| @stream_mechanisms.push(mech.text)}
        else
          @stream_features[e.name] = e.namespace
        end
      end
    end
  
    #.........................................................................................................
    def init_connection(jid, starting = true)
      msg = []
      msg.push(Send("<?xml version='1.0' ?>")) if starting
      msg.push(Send("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' version='1.0' to='#{jid.domain}'>"))
    end
          
  public
    
    #####-------------------------------------------------------------------------------------------------------
    class << self
      
      #---------------------------------------------------------------------------------------------------------
      # event flow delegate methods
      #.........................................................................................................
      # connection
      #.........................................................................................................
      def did_connect(pipe)
        AgentXmpp.logger.info "CONNECTED"
      end

      #.........................................................................................................
      def did_disconnect(pipe)
        AgentXmpp.logger.warn "DISCONNECTED"
        EventMachine::stop_event_loop
      end

      #.........................................................................................................
      def did_not_connect(pipe)
        AgentXmpp.logger.warn "CONNECTION FAILED"
      end

      #.........................................................................................................
      # authentication
      #.........................................................................................................
      def did_start_session(pipe, stanza)
        AgentXmpp.logger.info "SESSION STARTED"
        Xmpp::IqRoster.get(pipe)
      end

      #.........................................................................................................
      # presence
      #.........................................................................................................
      def did_receive_presence(pipe, presence)
        from_jid = presence.from.to_s     
        from_bare_jid = presence.from.bare.to_s     
        if pipe.roster.has_key?(from_bare_jid) 
          pipe.roster[from_bare_jid.to_s][:resources][from_jid] = {} if pipe.roster[from_bare_jid.to_s][:resources][from_jid].nil?
          pipe.roster[from_bare_jid.to_s][:resources][from_jid][:presence] = presence
          AgentXmpp.logger.info "RECEIVED PRESENCE FROM: #{from_jid}"
          Xmpp::IqVersion.request(from_jid, pipe) if not from_jid.eql?(pipe.jid.to_s) and presence.type.nil?
        else
          AgentXmpp.logger.warn "RECEIVED PRESENCE FROM JID NOT IN ROSTER: #{from_jid}" 
        end
      end

      #.........................................................................................................
      def did_receive_presence_subscribe(pipe, presence)
        from_jid = presence.from.to_s     
        if pipe.roster.has_key?(presence.from.bare.to_s ) 
          AgentXmpp.logger.info "RECEIVED SUBSCRIBE REQUEST: #{from_jid}"
          Xmpp::Presence.accept(from_jid)  
        else
          AgentXmpp.logger.warn "RECEIVED SUBSCRIBE REQUEST FROM JID NOT IN ROSTER: #{from_jid}"        
          Xmpp::Presence.decline(from_jid)  
        end
      end

      #.........................................................................................................
      def did_receive_presence_unsubscribed(pipe, presence)
        from_jid = presence.from.to_s     
        if pipe.roster.delete(presence.from.bare.to_s )           
          AgentXmpp.logger.info "RECEIVED UNSUBSCRIBED REQUEST: #{from_jid}"
          Xmpp::IqRoster.remove(presence.from, pipe)  
        else
          AgentXmpp.logger.warn "RECEIVED UNSUBSCRIBED REQUEST FROM JID NOT IN ROSTER: #{from_jid}"   
        end
      end

      #.........................................................................................................
      def did_receive_presence_subscribed(pipe, presence)
        from_jid = presence.from.to_s     
        AgentXmpp.logger.warn "SUBSCRIPTION ACCEPTED: #{from_jid}" 
      end

      #.........................................................................................................
      # roster management
      #.........................................................................................................
      def did_receive_roster_item(pipe, roster_item)
        AgentXmpp.logger.info "RECEIVED ROSTER ITEM"   
        roster_item_jid = roster_item.jid.to_s
        if pipe.roster.has_key?(roster_item_jid) 
          case roster_item.subscription   
          when :none
            if roster_item.ask.eql?(:subscribe)
              AgentXmpp.logger.info "CONTACT SUBSCRIPTION PENDING: #{roster_item_jid}"   
              pipe.roster[roster_item_jid][:status] = :ask 
            else
              AgentXmpp.logger.info "CONTACT ADDED TO ROSTER: #{roster_item_jid}"   
              pipe.roster[roster_item_jid][:status] = :added 
            end
          when :to
            AgentXmpp.logger.info "SUBSCRIBED TO CONTACT PRESENCE: #{roster_item_jid}"   
            pipe.roster[roster_item_jid][:status] = :to 
          when :from
            AgentXmpp.logger.info "CONTACT SUBSCRIBED TO PRESENCE: #{roster_item_jid}"   
            pipe.roster[roster_item_jid][:status] = :from 
          when :both    
            AgentXmpp.logger.info "CONTACT SUBSCRIPTION BIDIRECTIONAL: #{roster_item_jid}"   
            pipe.roster[roster_item_jid][:status] = :both 
            pipe.roster[roster_item_jid][:roster_item] = roster_item 
          end
        else
          AgentXmpp.logger.info "REMOVING ROSTER ITEM: #{roster_item_jid}"   
          Xmpp::IqRoster.remove(roster_item.jid, pipe)  
        end
      end

      #.........................................................................................................
      def did_remove_roster_item(pipe, roster_item)
        AgentXmpp.logger.info "REMOVE ROSTER ITEM"   
        roster_item_jid = roster_item.jid.to_s
        if pipe.roster.has_key?(roster_item_jid) 
          AgentXmpp.logger.info "REMOVED ROSTER ITEM: #{roster_item_jid}"   
          pipe.roster.delete(roster_item_jid) 
        end
      end

      #.........................................................................................................
      def did_receive_all_roster_items(pipe)
        AgentXmpp.logger.info "RECEIVED ALL ROSTER ITEMS"   
        pipe.roster.select{|j,r| r[:status].eql?(:inactive)}.collect do |j, r|
          AgentXmpp.logger.info "ADDING CONTACT: #{j}" 
          Xmpp::IqRoster.add(Xmpp::JID.new(j), pipe)  
        end
      end

      #.........................................................................................................
      def did_receive_add_roster_item_error(pipe, response, roster_item_jid)
        AgentXmpp.logger.info "ADD ROSTER ITEM RECEIVED ERROR REMOVING: #{roster_item_jid.to_s}"
        pipe.roster.delete(roster_item_jid)
      end

      #.........................................................................................................
      # service discovery management
      #.........................................................................................................
      def did_receive_client_version_result(pipe, from, version)
        if pipe.roster.has_key?(from.bare.to_s)
          AgentXmpp.logger.info "RECEIVED CLIENT VERSION RESULT: #{from.to_s}, #{version.iname}, #{version.version}"
          pipe.roster[from.bare.to_s][:resources][from.to_s][:version] = version
        else
          AgentXmpp.logger.warn "RECEIVED CLIENT VERSION RESULT FROM JID NOT IN ROSTER: #{from.to_s}"
        end        
      end

      #.........................................................................................................
      def did_receive_client_version_get(pipe, request)
        if pipe.roster.has_key?(request.from.bare.to_s)
          AgentXmpp.logger.info "RECEIVED CLIENT VERSION REQUEST: #{request.from.to_s}"
          Xmpp::IqVersion.respond(request, pipe)
        else
          AgentXmpp.logger.warn "RECEIVED CLIENT VERSION REQUEST FROM JID NOT IN ROSTER: #{request.from.to_s}"
        end
      end
         
    #### self
    end
     
  #### MessagePipe
  end

#### AgentXmpp
end
