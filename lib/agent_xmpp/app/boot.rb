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

        ####..............
        raise AgentXmppError, "Configuration file #{AgentXmpp.config_file} required." unless File.exist?(AgentXmpp.config_file) 
        begin
          require add_path('boot')
        rescue LoadError
          AgentXmpp.logger.info "boot.rb not given"
        else
          AgentXmpp.logger.info "boot.rb loaded"
        end

        ####..............
        call_if_implemented(:call_before_start)
        AgentXmpp::Client.new(File.open(AgentXmpp.config_file) {|yf| YAML::load(yf)}).connect
        
      end
      
      #.......................................................................................................
      def pwd
        Dir.pwd
      end
      
      ####....................................................................................................
      # application deligate methods
      #.......................................................................................................
      def call_if_implemented(method, *args)
        send(method, *args) if respond_to?(method)
      end
      
      #.......................................................................................................
      def before_start(&blk)
         define_meta_class_method(:call_before_start, &blk)
      end

      #.......................................................................................................
      def after_connected(&blk)
         define_meta_class_method(:call_after_connected, &blk)
      end

      #.......................................................................................................
      def restarting_server(&blk)
         define_meta_class_method(:call_restarting_server, &blk)
      end
                    
    ####......................................................................................................
    private

      #.......................................................................................................
      def add_path(dir)
        File.join(AgentXmpp.app_path, dir)
      end
    
    #### self
    end

  #### Boot
  end
  
#### AgentXmpp
end
