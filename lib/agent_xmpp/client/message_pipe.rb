##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class MessagePipe

    #---------------------------------------------------------------------------------------------------------
    attr_reader   :connection_status, :delegates, :responder_list, :stream_features, 
                  :stream_mechanisms, :responder_list_mutex
    #---------------------------------------------------------------------------------------------------------
    attr_accessor :connection
    #---------------------------------------------------------------------------------------------------------
    alias_method :send_to_method, :send
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize
      @connection_status = :not_authenticated;
      @delegates = [MessageDelegate]
      @responder_list = {}
      @responder_list_mutex = Mutex.new
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
    def send(data, &blk)
      raise AgentXmppError, 'not connected'  unless connected?
      if block_given? and data.kind_of?(Xmpp::Stanza)
        if data.id.nil?
          data.id = Xmpp::IdGenerator.generate_id
        end
        add_to_responder_list(data.id, &blk)
      end
      AgentXmpp.logger.info "SEND: #{data.to_s}"
      Message.update(data)
      connection.send_data(data.to_s)
    end

    #.........................................................................................................
    def send_resp(resp)
      [resp].flatten.map {|r| r.kind_of?(AgentXmpp::Response) ? send(r.message, &r.responds_with) : r}
    end

    #.........................................................................................................
    def connected?
      connection and !connection.error?
    end
 
    #.........................................................................................................
    def add_to_responder_list(stanza_id, &blk)
      responder_list_mutex.synchronize do
        @responder_list[stanza_id] = {:blk=>blk, :created_at=>Time.now}
      end
    end
 
    #.........................................................................................................
    def remove_from_responder_list(stanza_id)
      if @responder_list[stanza_id]
        responder_list_mutex.synchronize{@responder_list.delete(stanza_id)}
      end
    end
    
    #---------------------------------------------------------------------------------------------------------
    # connection callbacks
    #.........................................................................................................
    def receive(stanza)
      AgentXmpp.logger.info "RECV: #{stanza.to_s}"
      result = if stanza.kind_of?(Xmpp::Stanza) and stanza.id and callback_info = responder_list[stanza.id]
                 responder_list.delete(stanza.id)
                 callback_info[:blk].call(stanza)
               else
                 process_stanza(stanza)
               end
      send_resp(result)          
    end

    #.........................................................................................................
    def connection_completed
      Boot.call_if_implemented(:call_after_connected, self)     
      broadcast_to_delegates(:on_connect, self)
      init_connection.collect{|m| send(m)}
    end

    #.........................................................................................................
    def unbind
      @connection_status = :off_line
      broadcast_to_delegates(:on_disconnect, self)
    end
    
    #.........................................................................................................
    # private
    #.........................................................................................................
    def process_stanza(stanza)
      case stanza.name
      when 'features'
        set_stream_features_and_mechanisms(stanza)
        if connection_status.eql?(:not_authenticated)
          broadcast_to_delegates(:on_preauthenticate_features, self)
        elsif connection_status.eql?(:authenticated)
          broadcast_to_delegates(:on_postauthenticate_features, self)
        end
      when 'stream'
      when 'success'
        if connection_status.eql?(:not_authenticated)
          connection.reset_parser
          @connection_status = :authenticated
          broadcast_to_delegates(:on_authenticate, self)
          init_connection(false)
        end
      when 'failure'
        if connection_status.eql?(:not_authenticated)
          @connection.reset_parser
          broadcast_to_delegates(:on_did_not_authenticate, self)
        end
      else
        demux_stanza(stanza)
      end
    end
  
    #.........................................................................................................
    def demux_stanza(stanza)
      if stanza.respond_to?(:id) and not Message.find_by_item_id(stanza.id)
        Message.update(stanza)
        meth = 'on_' + if stanza.class.eql?(AgentXmpp::Xmpp::Iq)
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
          broadcast_to_delegates(:on_unsupported_message, self, stanza)
        end
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
     
    #.........................................................................................................
     private :process_stanza, :demux_stanza, :set_stream_features_and_mechanisms, :init_connection
         
  #### MessagePipe
  end

#### AgentXmpp
end
