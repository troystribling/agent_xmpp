$:.unshift(File.dirname(__FILE__))

require 'find'
require 'ftools'
require 'optparse'

require 'eventmachine'
require 'evma_xmlpushparser'
require 'xmpp4r'
require 'xmpp4r/roster'
require 'xmpp4r/version'
require 'xmpp4r/dataforms'
require 'xmpp4r/command/iq/command'

require 'agent_xmpp/config'
require 'agent_xmpp/app'
require 'agent_xmpp/client'
require 'agent_xmpp/utils'
require 'agent_xmpp/patches'
  
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
  module Delegator 

    class << self
      
      def delegate(*methods)
        methods.each do |method_name|
          class_eval <<-RUBY
            def #{method_name.to_s}(*args, &blk)
              ::AgentXmpp::BaseController.send(#{method_name.inspect}, *args, &blk)
            end
            private #{method_name.inspect}
          RUBY
        end
      end
      
    end

    delegate :execute, :chat
  
  end
end

##############################################################################################################
include AgentXmpp::Delegator

##############################################################################################################
at_exit {AgentXmpp::Boot.boot}
