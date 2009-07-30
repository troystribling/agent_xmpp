##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class Client

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      def command(args)
        raise ArgmentError ':to and :node are required' unless args[:to] and args[:node]
        iq = Xmpp::Iq.new(:set, args[:to])
        iq.command = Xmpp::IqCommand.new(args[:node])
        iq.command.action = :execute
        iq.command << args[:params].to_x_data(:submit) if args[:params]
        Send(iq) do |r|
          if block_given?
            status = r.type
            data = (status.eql?(:result) and r.command and r.command.x) ? r.command.x.to_natve : nil
            yield(status, data) 
          end
        end     
      end

    #### self
    end
    
    #---------------------------------------------------------------------------------------------------------
    attr_reader :port, :password, :connection, :config, :priority
    attr_accessor :jid
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize(config)
      @password = config['password']
      @port = config['port'] || 5222
      @priority = set_priority(config['priority'])
      resource = config['resource'] || Socket.gethostname
      @config = config
      @jid = Xmpp::Jid.new("#{config['jid']}/#{resource}")
    end

    #.........................................................................................................
    def connect
      while (true)
        EventMachine.run do
          @connection = EventMachine.connect(jid.domain, port, Connection, self)
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
    
  private
  
    #.........................................................................................................
    def set_priority(pri)
      if pri
        pri = -127 if pri < -127
        pri = 128 if pri > 128
        pri
      else; 1; end
    end
      
  #### Client
  end

#### AgentXmpp
end
