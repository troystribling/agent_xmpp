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
      def app_dir
        Dir.pwd
      end
      
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
    
      ####------------------------------------------------------------------------------------------------------
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
