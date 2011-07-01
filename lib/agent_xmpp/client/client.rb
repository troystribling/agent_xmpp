##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class Client

    #####-------------------------------------------------------------------------------------------------------
    class << self

    #### self
    end
    
    #---------------------------------------------------------------------------------------------------------
    attr_reader :connection
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize
    end

    #.........................................................................................................
    def connect(pipe)
      while (true)
        EventMachine.run do
          @connection = EventMachine.connect(AgentXmpp.jid.domain, AgentXmpp.port, Connection, pipe)
        end
        Boot.call_if_implemented(:call_restarting_client, pipe)     
        sleep(10.0)
        AgentXmpp.logger.warn "RESTARTING CLIENT"
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
    def pipe
      connection.pipe
    end

    #.........................................................................................................
    def add_delegate(delegate)
      connection.pipe.add_delegate(delegate)
    end

    #.........................................................................................................
    def remove_delegate(delegate)
      connection.pipe.remove_delegate(delegate)
    end
    
  #### Client
  end

#### AgentXmpp
end
