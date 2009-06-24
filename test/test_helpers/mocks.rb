##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  class Connection 
  
    #.........................................................................................................
    def self.new(*args)
      allocate.instance_eval do
        initialize(*args)
        connection_completed
        self
      end
    end
  
    #.........................................................................................................
    def send_data(data)
      data
    end

    def connection_completed
      message_pipe.connection_completed
    end

    #.........................................................................................................
    def error?
      false
    end

    #.........................................................................................................
    def reset_parser
    end
      
  #### Connection  
  end

  #####-------------------------------------------------------------------------------------------------------
  class Client 
  
    #.........................................................................................................
    def connect
      @connection = AgentXmpp::Connection.new(self, jid, password, message_pipe, port)    
    end

    #.........................................................................................................
    def reconnect
      true
    end
    
  #### Client  
  end

  #####-------------------------------------------------------------------------------------------------------
  class Controller

    #.........................................................................................................
    def handle_request     
      request_callback(request)
    end
        
  #### Controller
  end

#### AgentXmpp
end

##############################################################################################################
module Jabber

  #####-------------------------------------------------------------------------------------------------------
  class IdGenerator

    #.........................................................................................................
    def generate_id
      1
    end

  #### IdGenerator
  end

#### Jabber  
end
