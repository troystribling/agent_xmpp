##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class Connection < EventMachine::Connection

    #---------------------------------------------------------------------------------------------------------
    include EventMachine::XmlPushParser
    #---------------------------------------------------------------------------------------------------------

    #---------------------------------------------------------------------------------------------------------
    attr_reader :client, :jid, :port, :password, :connection_status, :delegates, :keepalive, :pipe               
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize(client, jid, password, pipe, port=5222)
      @client, @jid, @password, @pipe, @port = client, jid, password, pipe, port
      @connection_status = :offline;
      @pipe.connection = self
    end
    
    #---------------------------------------------------------------------------------------------------------
    # EventMachine::Connection callbacks
    #.........................................................................................................
    def connection_completed
      @keepalive = EventMachine::PeriodicTimer.new(60) do 
        send_data("\n")
      end
      pipe.connection_completed
    end

    #.........................................................................................................
    def receive_data(data)
      super(data)
    end

    #.........................................................................................................
    def unbind
      if @keepalive
        @keepalive.cancel
        @keepalive = nil
      end
      pipe.unbind
    end

    #---------------------------------------------------------------------------------------------------------
    # EventMachine::XmlPushParser callbacks
    #.........................................................................................................
  	def start_document
  	end
  
    #.........................................................................................................
    def start_element(name, attrs)
      e = REXML::Element.new(name)
      e.add_attributes(attrs)      
      @current = @current.nil? ? e : @current.add_element(e)  
      if @current.xpath == 'stream:stream'
        process
        @current = nil
      end
    end
  
    #.........................................................................................................
    def end_element(name)
      if @current.parent
        @current = @current.parent
      else
        process
        @current = nil
      end
    end

    #.........................................................................................................
    def characters(text)
      @current.text = @current.text.to_s + text if @current
    end
    
    #.........................................................................................................
    def error(*args)
      AgentXmpp.logger.error *args
    end

    #.........................................................................................................
    def process
      @current.add_namespace(@streamns) if @current.namespace('').to_s.eql?('')
      begin
        stanza = Xmpp::XMPPStanza::import(@current)
      rescue Xmpp::NoNameXmlnsRegistered
        stanza = @current
      end
      if @current.xpath.eql?('stream:stream')
        @streamns = @current.namespace('') if @current.namespace('')
      end
      receive(stanza) if respond_to?(:receive)
    end
  
    #.........................................................................................................
    def receive(stanza)
      pipe.receive(stanza)
    end
  
  #### Connection
  end

#### AgentXmpp
end
