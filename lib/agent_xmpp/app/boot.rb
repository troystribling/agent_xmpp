##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  class Boot
    
    #.......................................................................................................
    @config_load_order = []
    @app_load_order = []
    
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
        raise AgentXmppError, "Configuration file #{AgentXmpp.config_file} required." unless File.exist?(AgentXmpp.config_file) 
        begin
          require add_path('config/boot')
        rescue LoadError
          AgentXmpp.logger.info "config/boot.rb not given"
        end

        ####..............
        AgentXmpp.logger.info "STARTING AgentXmpp"
        AgentXmpp.logger.info "APPLICATION PATH: #{AgentXmpp.config_file}"
        AgentXmpp.logger.info "LOG FILE: #{AgentXmpp.log_file.kind_of?(String) ? AgentXmpp.log_file : "STDOUT"}"
        AgentXmpp.logger.info "CONFIGURATION FILE: #{AgentXmpp.config_file}"

        ####..............
        call_before_config_load if AgentXmpp::Boot.respond_to?(:call_before_config_load)
        load(add_path('config'), {:exclude => [add_path('config/boot')], :ordered_load => AgentXmpp::Boot.config_load_order})

        ####..............
        call_before_app_load if AgentXmpp::Boot.respond_to?(:call_before_app_load)
        load(add_path('app/models'), {:ordered_load => AgentXmpp::Boot.app_load_order})
        load(add_path('app/controllers'))
        call_after_app_load if AgentXmpp::Boot.respond_to?(:call_after_app_load)

        ####..............
        AgentXmpp::Client.new(File.open(AgentXmpp.config_file) {|yf| YAML::load(yf)}).connect
        
      end
      
      #.......................................................................................................
      def pwd
        Dir.pwd
      end
      
      ####....................................................................................................
      # application deligate methods
      #.......................................................................................................
      def before_config_load(&blk)
         define_meta_class_method(:call_before_config_load, &blk)
      end

      #.......................................................................................................
      def after_connection_completed(&blk)
         define_meta_class_method(:call_after_connection_completed, &blk)
      end

      #.......................................................................................................
      def before_app_load(&blk)
         define_meta_class_method(:call_before_app_load, &blk)
      end

      #.......................................................................................................
      def after_app_load(&blk)
         define_meta_class_method(:call_after_app_load, &blk)
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
    
      #.......................................................................................................
      def load(path, options = {})
        exclude_files = options[:exclude] || []
        ordered_files = options[:ordered_load] || []
        ordered_files.each{|f| require f}
        Find.find(path) do |file_path|
          if file_match = /(.*)\.rb$/.match(file_path)
            file = file_match.captures.last
            unless exclude_files.include?(file) and ordered_files.include?(file)
              require file 
            end
          end
        end
      end
      
    end
    ####......................................................................................................

  #### Boot
  end
  
#### AgentXmpp
end
