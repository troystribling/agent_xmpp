##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class MessagePipe

    #---------------------------------------------------------------------------------------------------------
    attr_reader   :connection_status, :delegates, :id_callbacks, :connection, :stream_features, \
                  :stream_mechanisms, :config
    #---------------------------------------------------------------------------------------------------------
    alias_method :send_to_method, :send
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize(connection, config)
      @connection = connection
      @connection_status = :offline;
      @delegates = [self.class]
      @config = config
      @id_callbacks = {}
    end
    
    #.........................................................................................................
    def roster
      @roster ||= RosterModel.new(connection.jid, config['roster'])
    end
    
    #.........................................................................................................
    def jid
      connection.jid
    end

    #.........................................................................................................
    def jid=(jid)
      connection.jid = jid
    end

    #.........................................................................................................
    def password
      connection.password
    end
    
    #.........................................................................................................
    def add_delegate(delegate)
      @delegates << delegate unless @delegates.include?(delegate)
    end

    #.........................................................................................................
    def remove_delegate(delegate)
      @delegates.delete(delegate)
    end
    
    #.........................................................................................................
    def delegates_respond_to?(method)
     delegates.inject(0){|r,d| d.respond_to?(method) ? r + 1 : r} > 0
    end
    
    #.........................................................................................................
    def broadcast_to_delegates(method, *args)
      delegates.inject([]){|r,d| d.respond_to?(method) ? r.push(d.send(method, *args)) : r}.smash
    end

    #.........................................................................................................
    def responder_list
      @id_callbacks
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
      [resp].flatten.inject([]) do |m, r| 
        r.kind_of?(AgentXmpp::Response) ? m.push(send(r.message, &r.responds_with)) : m
      end
    end

    #.........................................................................................................
    def connected?
      connection and !connection.error?
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
          broadcast_to_delegates(:did_receive_preauthenticate_features, self)
        elsif connection_status.eql?(:authenticated)
          broadcast_to_delegates(:did_receive_postauthenticate_features, self)
        end
      when 'stream'
      when 'success'
        if connection_status.eql?(:offline)
          @connection.reset_parser
          @connection_status = :authenticated
          broadcast_to_delegates(:did_authenticate, self)
          init_connection(jid, false)
        end
      when 'failure'
        if connection_status.eql?(:offline)
          @connection.reset_parser
          broadcast_to_delegates(:did_not_authenticate, self)
        end
      else
        demux_stanza(stanza)
      end
    end
  
    #.........................................................................................................
    def demux_stanza(stanza)
      meth = 'did_receive_' + if stanza.class.eql?(AgentXmpp::Xmpp::Iq)
                                iqclass = if stanza.query
                                            stanza.query.class
                                          elsif stanza.command
                                            stanza.command.class
                                          else
                                            nil
                                          end
                                if iqclass
                                  /.*::Iq(.*)/.match(iqclass.to_s).to_a.last 
                                else
                                  'fail'
                                end
                              else
                                /.*::(.*)/.match(stanza.class.to_s).to_a.last
                              end.downcase
      meth += '_' + stanza.type.to_s if stanza.type
      if delegates_respond_to?(meth.to_sym) 
        broadcast_to_delegates(meth.to_sym, self, stanza)
      else
        broadcast_to_delegates(:did_receive_unsupported_message, self, stanza)
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
      # process commands
      #.........................................................................................................
      def did_receive_command_set(pipe, stanza)
        command = stanza.command
        params = {:xmlns => 'jabber:x:data', :action => command.action, :to => stanza.from.to_s, 
          :from => stanza.from.to_s, :node => command.node, :id => stanza.id, :fields => {}}
        AgentXmpp.logger.info "RECEIVED COMMAND NODE: #{command.node}, FROM: #{stanza.from.to_s}"
        Controller.new(pipe, params).invoke_command
      end

      #.........................................................................................................
      # process chat messages
      #.........................................................................................................
      def did_receive_message_chat(pipe, stanza)
        params = {:xmlns => 'message:chat', :to => stanza.from.to_s, :from => stanza.from.to_s, :id => stanza.id, \
          :body => stanza.body}
        AgentXmpp.logger.info "RECEIVED MESSAGE BODY: #{stanza.body}"
        Controller.new(pipe, params).invoke_chat
      end

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
      def did_bind(pipe)
        AgentXmpp.logger.info "DID BIND TO RESOURCE: #{pipe.jid.resource}"
      end

      #.........................................................................................................
      def did_receive_preauthenticate_features(pipe)
        AgentXmpp.logger.info "SESSION INITIALIZED"
        Xmpp::SASL.authenticate(pipe, pipe.stream_mechanisms)
      end

      #.........................................................................................................
      def did_authenticate(pipe)
        AgentXmpp.logger.info "AUTHENTICATED"
      end

      #.........................................................................................................
      def did_not_authenticate(pipe)
        AgentXmpp.logger.info "AUTHENTICATION FAILED"
        raise AgentXmppError, "authentication failed"
      end

      #.........................................................................................................
      def did_receive_postauthenticate_features(pipe)
        AgentXmpp.logger.info "SESSION STARTED"
        Xmpp::Iq.bind(pipe) if \
          pipe.stream_features.has_key?('bind') and pipe.stream_features.has_key?('session')
      end

 
      #.........................................................................................................
      def did_start_session(pipe)
        AgentXmpp.logger.info "SESSION STARTED"
        [Xmpp::IqRoster.get(pipe), Xmpp::IqDiscoInfo.get(pipe, pipe.jid.domain)]
      end

      #.........................................................................................................
      # presence
      #.........................................................................................................
      def did_receive_presence(pipe, presence)
        if pipe.roster.has_jid?(presence.from) 
          from_jid = presence.from    
          pipe.roster.update_resource(presence)
          AgentXmpp.logger.info "RECEIVED PRESENCE FROM: #{from_jid.to_s }"
          response = []
          unless from_jid.to_s.eql?(pipe.jid.to_s)
            response << Xmpp::IqVersion.request(pipe, from_jid) unless pipe.roster.has_version?(from_jid)
            response << Xmpp::IqDiscoInfo.get(pipe, from_jid) unless pipe.roster.has_discoinfo?(from_jid)
          end
          response
        else
          AgentXmpp.logger.warn "RECEIVED PRESENCE FROM JID NOT IN ROSTER: #{from_jid}" 
        end
      end

      #.........................................................................................................
      def did_receive_presence_subscribe(pipe, presence)
        from_jid = presence.from.to_s     
        if pipe.roster.has_jid?(presence.from) 
          AgentXmpp.logger.info "RECEIVED SUBSCRIBE REQUEST: #{from_jid}"
          Xmpp::Presence.accept(from_jid)  
        else
          AgentXmpp.logger.warn "RECEIVED SUBSCRIBE REQUEST FROM JID NOT IN ROSTER: #{from_jid}"        
          Xmpp::Presence.decline(from_jid)  
        end
      end

      #.........................................................................................................
      def did_receive_presence_subscribed(pipe, presence)
        AgentXmpp.logger.warn "SUBSCRIPTION ACCEPTED: #{presence.from.to_s}" 
      end

      #.........................................................................................................
      def did_receive_presence_unavailable(pipe, presence)
        from_jid = presence.from    
        if pipe.roster.has_jid?(from_jid) 
          pipe.roster.update_resource(presence)
          AgentXmpp.logger.info "RECEIVED UNAVAILABLE PRESENCE FROM: #{from_jid.to_s }"
        else
          AgentXmpp.logger.warn "RECEIVED UNAVAILABLE PRESENCE FROM JID NOT IN ROSTER: #{from_jid}"   
        end
      end

      #.........................................................................................................
      def did_receive_presence_unsubscribed(pipe, presence)
        from_jid = presence.from.to_s     
        if pipe.roster.destroy_by_jid(presence.from)           
          AgentXmpp.logger.info "RECEIVED UNSUBSCRIBED REQUEST: #{from_jid}"
          Xmpp::IqRoster.remove(pipe, presence.from)  
        else
          AgentXmpp.logger.warn "RECEIVED UNSUBSCRIBED REQUEST FROM JID NOT IN ROSTER: #{from_jid}"   
        end
      end

      #.........................................................................................................
      # roster management
      #.........................................................................................................
      def did_receive_roster_result(pipe, stanza)
        process_roster_items(pipe, stanza)
      end

      #.........................................................................................................
      def did_receive_roster_set(pipe, stanza)
        process_roster_items(pipe, stanza)
      end

     #.........................................................................................................
      def did_receive_roster_item(pipe, roster_item)
        roster_item_jid = roster_item.jid
        AgentXmpp.logger.info "RECEIVED ROSTER ITEM: #{roster_item_jid.to_s}"   
        if pipe.roster.has_jid?(roster_item_jid) 
          case roster_item.subscription   
          when :none
            if roster_item.ask.eql?(:subscribe)
              AgentXmpp.logger.info "CONTACT SUBSCRIPTION PENDING: #{roster_item_jid.to_s}"   
              pipe.roster.update_status(roster_item_jid, :ask) 
            else
              AgentXmpp.logger.info "CONTACT ADDED TO ROSTER: #{roster_item_jid.to_s}"   
              pipe.roster.update_status(roster_item_jid, :added)
            end
          when :to
            AgentXmpp.logger.info "SUBSCRIBED TO CONTACT PRESENCE: #{roster_item_jid.to_s}"   
            pipe.roster.update_status(roster_item_jid, :to) 
          when :from
            AgentXmpp.logger.info "CONTACT SUBSCRIBED TO PRESENCE: #{roster_item_jid.to_s}"   
            pipe.roster.update_status(roster_item_jid, :from) 
          when :both    
            AgentXmpp.logger.info "CONTACT SUBSCRIPTION BIDIRECTIONAL: #{roster_item_jid.to_s}"   
            pipe.roster.update_status(roster_item_jid, :both) 
            pipe.roster.update_roster_item(roster_item)
          end
        else
          AgentXmpp.logger.info "REMOVING ROSTER ITEM: #{roster_item_jid.to_s}"   
          Xmpp::IqRoster.remove(pipe, roster_item_jid)  
        end
      end

      #.........................................................................................................
      def did_remove_roster_item(pipe, roster_item)
        AgentXmpp.logger.info "REMOVE ROSTER ITEM"   
        roster_item_jid = roster_item.jid
        if pipe.roster.has_jid?(roster_item_jid) 
          AgentXmpp.logger.info "REMOVED ROSTER ITEM: #{roster_item_jid.to_s}"   
          pipe.roster.destroy_by_jid(roster_item_jid) 
        end
      end

      #.........................................................................................................
      def did_receive_all_roster_items(pipe)
        AgentXmpp.logger.info "RECEIVED ALL ROSTER ITEMS"   
        pipe.roster.find_all_by_status(:inactive).collect do |j, r|
          AgentXmpp.logger.info "ADDING CONTACT: #{j}" 
          Xmpp::IqRoster.add(pipe, j)  
        end
      end

      #.........................................................................................................
      def did_acknowledge_add_roster_item(pipe, response)
        AgentXmpp.logger.info "ADD ROSTER ITEM ACKNOWLEDEGED"   
      end

      #.........................................................................................................
      def did_acknowledge_remove_roster_item(pipe, response)
        AgentXmpp.logger.info "REMOVE ROSTER ITEM ACKNOWLEDEGED"   
      end

      #.........................................................................................................
      def did_receive_add_roster_item_error(pipe, roster_item_jid)
        AgentXmpp.logger.info "ADD ROSTER ITEM RECEIVED ERROR REMOVING: #{roster_item_jid}"
        pipe.roster.destroy_by_jid(Xmpp::JID.new(roster_item_jid))
      end

      #.........................................................................................................
      def did_receive_remove_roster_item_error(pipe, roster_item_jid)
        AgentXmpp.logger.info "REMOVE ROSTER ITEM RECEIVED ERROR REMOVING: #{roster_item_jid}"
        pipe.roster.destroy_by_jid(Xmpp::JID.new(roster_item_jid))
      end

      #.........................................................................................................
      # service discovery management
      #.........................................................................................................
      def did_receive_version_result(pipe, version)
        version_jid = version.from
        if pipe.roster.has_jid?(version_jid)
          query = version.query
          AgentXmpp.logger.info "RECEIVED VERSION RESULT: #{version_jid.to_s}, #{query.iname}, #{query.version}"
          pipe.roster.update_resource_version(version)
        else
          AgentXmpp.logger.warn "RECEIVED VERSION RESULT FROM JID NOT IN ROSTER: #{from.to_s}"
        end        
      end

      #.........................................................................................................
      def did_receive_version_get(pipe, request)
        if pipe.roster.has_jid?(request.from)
          AgentXmpp.logger.info "RECEIVED VERSION REQUEST: #{request.from.to_s}"
          Xmpp::IqVersion.result(pipe, request)
        else
          AgentXmpp.logger.warn "RECEIVED VERSION REQUEST FROM JID NOT IN ROSTER: #{request.from.to_s}"
        end
      end
         
      #.........................................................................................................
      def did_receive_discoinfo_result(pipe, discoinfo)   
        from_jid = discoinfo.from
        if pipe.roster.has_jid?(from_jid)
          AgentXmpp.logger.info "RECEIVED DISCO INFO RESULT FROM: #{from_jid.to_s}"
          pipe.roster.update_resource_discoinfo(discoinfo)
          discoinfo.query.identities.each do |i|
            AgentXmpp.logger.info " IDENTITY: NAME:#{i.iname}, CATEGORY:#{i.category}, TYPE:#{i.type}"
          end
          discoinfo.query.features.each do |f|
            AgentXmpp.logger.info " FEATURE: #{f}"
          end
          Xmpp::IqDiscoItems.get(pipe, from_jid.to_s)
        else
          AgentXmpp.logger.warn "RECEIVED DISCO RESULT FROM JID NOT IN ROSTER: #{from_jid.to_s}"
        end        
      end

      #.........................................................................................................
      def did_receive_discoinfo_get(pipe, request)   
        from_jid = request.from
        if pipe.roster.has_jid?(from_jid)
          AgentXmpp.logger.info "RECEIVED DISCO INFO REQUEST: #{from_jid.to_s}"
          Xmpp::IqDiscoInfo.result(pipe, request)
        else
          AgentXmpp.logger.warn "RECEIVED DISCO INFO REQUEST FROM JID NOT IN ROSTER: #{from_jid.to_s}"
        end
      end

      #.........................................................................................................
      def did_receive_discoitems_get(pipe, request)   
        from_jid = request.from
        if pipe.roster.has_jid?(from_jid)
          if (request.query.node.eql?('http://jabber.org/protocol/commands'))
            AgentXmpp.logger.info "RECEIVED COMMAND NODE DISCO ITEMS REQUEST: #{from_jid.to_s}"
            Xmpp::IqDiscoItems.command_nodes(pipe, request)
          else
            AgentXmpp.logger.info "RECEIVED DISCO ITEMS REQUEST: #{from_jid.to_s}"
            Xmpp::IqDiscoItems.result(pipe, request)
          end
        else
          AgentXmpp.logger.warn "RECEIVED DISCO ITEMS REQUEST FROM JID NOT IN ROSTER: #{from_jid.to_s}"
        end
      end
      
      #.........................................................................................................
      def did_receive_discoitems_result(pipe, discoitems)
        from_jid = discoitems.from
        if pipe.roster.has_jid?(from_jid)
          AgentXmpp.logger.info "RECEIVED DISCO ITEMS RESULT FROM: #{discoitems.from.to_s}"
          pipe.roster.update_resource_discoitems(discoitems)
          discoitems.query.items.each do |i|
            AgentXmpp.logger.info " ITEM JID: #{i.jid}"
          end
        else
          AgentXmpp.logger.warn "RECEIVED DISCO ITEMS FROM JID NOT IN ROSTER: #{from_jid.to_s}"
        end        
      end
  
      #.........................................................................................................
      # errors
      #.........................................................................................................
      def did_receive_unsupported_message(pipe, stanza)
        AgentXmpp.logger.info "RECEIVED UNSUPPORTED MESSAGE: #{stanza.to_s}"
      end
      
    private
    
      #.........................................................................................................
      def process_roster_items(pipe, stanza)
        [stanza.query.inject([]) do |r, i|  
          method =  i.subscription.eql?(:remove) ? :did_remove_roster_item : :did_receive_roster_item
          r.push(pipe.broadcast_to_delegates(method, pipe, i))
        end, pipe.broadcast_to_delegates(:did_receive_all_roster_items, pipe)].smash
      end
    
    #### self
    end
     
  #### MessagePipe
  end

#### AgentXmpp
end
