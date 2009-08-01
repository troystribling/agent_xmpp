##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class MessagePipe

    #---------------------------------------------------------------------------------------------------------
    attr_reader   :connection_status, :delegates, :id_callbacks, :connection, :stream_features, 
                  :stream_mechanisms, :user_pubsub_node, :pubsub_root
    #---------------------------------------------------------------------------------------------------------
    alias_method :send_to_method, :send
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize(connection)
      @connection = connection
      @connection_status = :offline;
      @delegates = [MessageDelegate]
      @pubsub_root = "/home/#{AgentXmpp.jid.domain}"       
      @user_pubsub_node = "#{@pubsub_root}/#{AgentXmpp.jid.node}" 
      @id_callbacks = {}
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
      [resp].flatten.map {|r| r.kind_of?(AgentXmpp::Response) ? send(r.message, &r.responds_with) : r}
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
      Boot.call_if_implemented(:call_after_connected)     
      broadcast_to_delegates(:did_connect, self)
      init_connection.collect{|m| send(m)}
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
          init_connection(false)
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
    def init_connection(starting = true)
      msg = []
      msg.push(Send("<?xml version='1.0' ?>")) if starting
      msg.push(Send("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' version='1.0' to='#{AgentXmpp.jid.domain}'>"))
    end
         
  #### MessagePipe
  end

#### AgentXmpp
end
