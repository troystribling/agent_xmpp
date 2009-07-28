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

    delegate AgentXmpp::BaseController, :execute, :chat, :event
    delegate AgentXmpp::Boot, :before_start, :after_connected, :restarting_client, :discovered_all_publish_nodes,
                              :discovered_pubsub_node, :discovered_command_nodes
    delegate AgentXmpp::Client, :command

  #### Delegator 
  end
  
  #####-------------------------------------------------------------------------------------------------------
  class << self
  #### self
  end
  
#### AgentXmpp 
end

##############################################################################################################
include AgentXmpp::Delegator

##############################################################################################################
at_exit {AgentXmpp::Boot.boot}
