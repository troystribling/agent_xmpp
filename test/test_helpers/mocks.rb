##############################################################################################################
class AgentXmpp::Connection 
  
  #.........................................................................................................
  def self.new(*args)
    allocate.instance_eval do
      initialize(*args)
      connection_completed
      self
    end
  end
  
  #.........................................................................................................
  def send(data, &blk)
    if block_given? and data.is_a? Jabber::XMPPStanza
      if data.id.nil?
        data.id = 1
      end
      @id_callbacks[data.id] = blk
    end    
    AgentXmpp.logger.info "SEND: #{data.to_s}"
    data.to_s
  end

  #.........................................................................................................
  def connection_completed
    init_connection
    add_delegate(client)  
    broadcast_to_delegates(:did_connect, self)
  end

  #.........................................................................................................
  def error?
    false
  end

  #.........................................................................................................
  def reset_parser
  end
      
#### AgentXmpp::Connection  
end

##############################################################################################################
class AgentXmpp::Client 
  
  #.........................................................................................................
  def connect
    @connection = AgentXmpp::Connection.new(self, jid, password, port)    
  end

  #.........................................................................................................
  def connected?
    true
  end
    
  #.........................................................................................................
  def reconnect
    true
  end
    
#### AgentXmpp::Client  
end

##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class Controller

    #.........................................................................................................
    def respond_to(&blk)      
      View.new(connection, format, params).add_payload_to_container(blk.call(@result_for_blk.call))
    end
        
  #### Controller
  end

#### AgentXmpp
end
