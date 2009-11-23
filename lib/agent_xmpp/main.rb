##############################################################################################################
OptionParser.new do |opts|
  opts.banner = 'Usage: agent_xmpp.rb [options]'
  opts.separator ''
  opts.on('-c', '--config config.yml', 'YAML agent configuration file relative to application path') {|f| AgentXmpp.config_file = f}
  opts.on('-l', '--logfile file.log', 'name of logfile') {|f| AgentXmpp.log_file = f}
  opts.on_tail('-h', '--help', 'Show this message') {
    puts opts
    exit
  }
  opts.parse!(ARGV)
end

##############################################################################################################
module AgentXmpp
  
  #...........................................................................................................
  @config = {}

  #####-------------------------------------------------------------------------------------------------------
  class << self

    #.........................................................................................................
    attr_accessor :config
    
    #.........................................................................................................
    def in_memory_db
      @in_memory_db ||= Sequel.sqlite
    end

    #.........................................................................................................
    def agent_xmpp_db
      @agent_xmpp_db ||= Sequel.connect("sqlite://#{AgentXmpp.app_path}/agent_xmpp.db")
    end

    #.........................................................................................................
    def contacts
      @contacts ||= RosterModel.new(jid, config['roster'])
    end

    #.........................................................................................................
    def roster
      @roster ||= RosterModel.new(jid, config['roster'])
    end

    #.........................................................................................................
    def services
      @services ||= ServicesModel.new
    end
    
    #.........................................................................................................
    def publication
      @publication ||= PublishModel.new(config['publish'])
    end
        
    #.........................................................................................................
    def pubsub_root
      @pubsub_root ||= "/home/#{AgentXmpp.jid.domain}"  
    end     
    
    #.........................................................................................................
    def user_pubsub_root
      @user_pubsub_root ||= "#{@pubsub_root}/#{AgentXmpp.jid.node}" 
    end

    #.........................................................................................................
    def jid
      @jid ||= Xmpp::Jid.new("#{config['jid']}/#{resource}")
    end
      
    #.........................................................................................................
    def jid=(jid)
      @jid = jid
    end
          
    #.........................................................................................................
    def resource
      config['resource'] || Socket.gethostname
    end
         
    #.........................................................................................................
    def port
      config['port'] || 5222
    end

    #.........................................................................................................
    def password
      config['password']
    end
            
    #.........................................................................................................
    def priority
      @priority ||= if config['priority']
                    if config['priority'] < -127
                      -127
                    elsif config['priority'] > 128
                      128
                    else
                      config['priority']
                    end
                  else; 1; end
    end
            
  #### self
  end
  
  #####-------------------------------------------------------------------------------------------------------
  module Delegator 

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      def delegate(del, *methods)
        methods.each do |method_name|
          class_eval <<-RUBY
            def #{method_name.to_s}(*args, &blk)
              ::#{del}.send(#{method_name.inspect}, *args, &blk)
            end
          RUBY
        end
      end

    #### self
    end

    delegate AgentXmpp::BaseController, :command, :chat, :event
    delegate AgentXmpp::Boot, :before_start, :after_connected, :restarting_client, :discovered_pubsub_node, 
                              :discovered_command_nodes, :received_presence

  #### Delegator 
  end
    
#### AgentXmpp 
end

##############################################################################################################
include AgentXmpp::Delegator

##############################################################################################################
at_exit {AgentXmpp::Boot.boot}
