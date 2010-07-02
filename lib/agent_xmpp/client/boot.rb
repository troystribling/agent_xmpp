##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  class Boot
    
    ####......................................................................................................
    class << self

      ####....................................................................................................
      # start application
      #.......................................................................................................
      def boot
        
        AgentXmpp.log_file = add_path(AgentXmpp.log_file) if AgentXmpp.log_file.kind_of?(String)
        AgentXmpp.logger = Logger.new(AgentXmpp.log_file, 10, 1024000)
        AgentXmpp.logger.level = Logger::WARN 

        call_if_implemented(:call_before_start)

        AgentXmpp.logger.info "STARTING AgentXmpp"
        AgentXmpp.logger.info "APPLICATION PATH: #{AgentXmpp.app_path}"
        AgentXmpp.logger.info "LOG FILE: #{AgentXmpp.log_file.kind_of?(String) ? AgentXmpp.log_file : "STDOUT"}"
        AgentXmpp.logger.info "CONFIGURATION FILE: #{AgentXmpp.config_file}"

        raise AgentXmppError, "Configuration file #{AgentXmpp.config_file} required." unless File.exist?(AgentXmpp.config_file) 

        AgentXmpp.config = File.open(AgentXmpp.config_file) {|yf| YAML::load(yf)}
        
        AgentXmpp.create_agent_xmpp_db  
        AgentXmpp.create_in_memory_db        
        AgentXmpp.upgrade_agent_xmpp_db
        Contact.load_config 
        Publication.load_config 
                
        AgentXmpp::Client.new().connect
      
      end
      
      ####....................................................................................................
      # application deligate methods
      #.......................................................................................................
      def call_if_implemented(method, *args)
        send(method, *args) if respond_to?(method)
      end
      
      #.........................................................................................................
      def callbacks(*args)
        args.each do |meth| 
          instance_eval <<-do_eval
            def call_#{meth}(*args)
              @array_#{meth}.each{|m| m.call(*args)} unless @array_#{meth}.nil?
            end
            def #{meth}(&blk)
              (@array_#{meth} ||= []) << blk
            end
          do_eval
        end
      end       
                          
      ####......................................................................................................
      # private
      #.......................................................................................................
      def add_path(dir)
        File.join(AgentXmpp.app_path, dir)
      end
      
      private :add_path
        
    #### self
    end

    #.........................................................................................................
    callbacks(:before_start, :after_connected, :discovered_all_publish_nodes, :discovered_command_nodes, 
              :discovered_pubsub_node, :received_presence, :restarting_client)

  #### Boot
  end
  
#### AgentXmpp
end
