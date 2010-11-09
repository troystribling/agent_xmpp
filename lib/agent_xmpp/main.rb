##############################################################################################################
OptionParser.new do |opts|
  opts.banner = 'Usage: agent_xmpp.rb [options]'
  opts.separator ''
  opts.on('-a', '--app_path path', 'absolute path to application') {|a| AgentXmpp.app_path = a}
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
  @settings = {}
  @config = {}

  #####-------------------------------------------------------------------------------------------------------
  class << self

    #.........................................................................................................
    attr_accessor :config, :settings
    
    #####.....................................................................................................
    # settings
    #.........................................................................................................
    def set(key, value)
      @settings[key] = value
    end

    #####.....................................................................................................
    # database
    #.........................................................................................................
    def in_memory_db
      @in_memory_db ||= Sequel.sqlite
    end

    #.........................................................................................................
    def agent_xmpp_db
      @agent_xmpp_db ||= if settings[:agent_xmpp_db_adapter] 
                           settings[:agent_xmpp_db_adapter].call
                         else 
                           Sequel.sqlite("#{AgentXmpp.app_path}/agent_xmpp.db") 
                         end
    end

    #.........................................................................................................
    def version
      @version ||= agent_xmpp_db[:version]
    end

    #.........................................................................................................
    def publication
      @publication ||= PublishModel.new(config['publish'])
    end
        
    #####.....................................................................................................
    # pubsub nodes
    #.........................................................................................................
    def pubsub_root
      @pubsub_root ||= "/home/#{AgentXmpp.jid.domain}"  
    end     
    
    #.........................................................................................................
    def user_pubsub_root
      @user_pubsub_root ||= "#{@pubsub_root}/#{AgentXmpp.jid.node}" 
    end

    #####.....................................................................................................
    # client account configuration
    #.........................................................................................................
    def is_account_jid?(jid)
      @jid.bare.to_s.eql?(bare_jid_to_s(jid))
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
         
    #.........................................................................................................
    def bare_jid_to_s(jid)
      case jid
        when String then Xmpp::Jid.new(jid).bare.to_s
        when Xmpp::Jid then jid.bare.to_s
      else jid
      end 
    end  
           
    #.........................................................................................................
    def full_jid_to_s(jid)
      case jid
        when String then jid
        when Xmpp::Jid then jid.to_s
      else jid
      end 
    end  
            
    #.........................................................................................................
    def start_garbage_collection(pipe)
      EventMachine::PeriodicTimer.new(AgentXmpp::GARBAGE_COLLECTION_INTERVAL) do
        AgentXmpp.logger.info "GARBAGE COLLECTION IN PROGRESS ON INTERVAL: #{AgentXmpp::GARBAGE_COLLECTION_INTERVAL}"
        AgentXmpp::BaseController.commands_list.each do |(session, command_info)|
          AgentXmpp::BaseController.remove_command_from_list(session) if Time.now - command_info[:created_at] > AgentXmpp::GARBAGE_COLLECTION_INTERVAL
        end
        pipe.responder_list.each do |(stanza_id, command_info)|
          pipe.remove_from_responder_list(stanza_id) if Time.now - command_info[:created_at] > AgentXmpp::GARBAGE_COLLECTION_INTERVAL
        end
      end  
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

    delegate AgentXmpp, :set
    delegate AgentXmpp::BaseController, :command, :chat, :event, :before, :include_module
    delegate AgentXmpp::Boot, :before_start, :after_connected, :restarting_client, :discovered_pubsub_node, 
                              :discovered_command_nodes, :received_presence

  #### Delegator 
  end
    
#### AgentXmpp 
end

##############################################################################################################
include AgentXmpp::Delegator

##############################################################################################################
at_exit do
  AgentXmpp::Boot.boot
end
