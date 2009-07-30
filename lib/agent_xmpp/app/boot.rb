##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  class Boot
    
    #.......................................................................................................
    @config_load_order = []
    
    ####......................................................................................................
    class << self

      #.......................................................................................................
      attr_accessor :config_load_order, :app_load_order
      
      #.......................................................................................................
      def boot
        
        ####..............
        AgentXmpp.log_file = add_path(AgentXmpp.log_file) if AgentXmpp.log_file.kind_of?(String)
        AgentXmpp.config_file = add_path(AgentXmpp.config_file)
        AgentXmpp.logger = Logger.new(AgentXmpp.log_file, 10, 1024000)

        ####..............
        AgentXmpp.logger.info "STARTING AgentXmpp"
        AgentXmpp.logger.info "APPLICATION PATH: #{AgentXmpp.app_path}"
        AgentXmpp.logger.info "LOG FILE: #{AgentXmpp.log_file.kind_of?(String) ? AgentXmpp.log_file : "STDOUT"}"
        AgentXmpp.logger.info "CONFIGURATION FILE: #{AgentXmpp.config_file}"
        AgentXmpp.logger.level = Logger::WARN 

        ####..............
        raise AgentXmppError, "Configuration file #{AgentXmpp.config_file} required." unless File.exist?(AgentXmpp.config_file) 

        ####..............
        call_if_implemented(:call_before_start)
        AgentXmpp::Client.new(File.open(AgentXmpp.config_file) {|yf| YAML::load(yf)}).connect
        
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
            def #{meth}(&blk)
              define_meta_class_method(:call_#{meth}, &blk)
            end
          do_eval
        end
      end 
                          
    ####......................................................................................................
    private

      #.......................................................................................................
      def add_path(dir)
        File.join(AgentXmpp.app_path, dir)
      end
        
    #### self
    end

    #.........................................................................................................
    callbacks(:before_start, :after_connected, :discovered_all_publish_nodes, :discovered_command_nodes, 
              :discovered_pubsub_node, :received_presence, :restarting_client)

  #### Boot
  end
  
#### AgentXmpp
end
