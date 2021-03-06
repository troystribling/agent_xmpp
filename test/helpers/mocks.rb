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
      pipe.connection_completed
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
      @connection = AgentXmpp::Connection.new(self)    
    end

    #.........................................................................................................
    def reconnect
      true
    end
    
  #### Client  
  end

  #####-------------------------------------------------------------------------------------------------------
  class Controller
    def handle_request  
      request_callback(request).collect{|m| Send(Xmpp::Stanza::import(REXML::Document.new(m).root))}
    end
  end

  #####-------------------------------------------------------------------------------------------------------
  class Boot  
    def self.boot     
    end        
  end

#### AgentXmpp
end


##############################################################################################################
module AgentXmpp
  module Xmpp
    class IdGenerator
      @gen_id;
      class << self
        def set_gen_id(val=1); @gen_id = val; end
        def gen_id; @gen_id; end;
        def generate_id; @gen_id.kind_of?(Array) ? @gen_id.shift : @gen_id; end
      end
    end
  end
end
