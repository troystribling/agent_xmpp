$:.unshift('lib')
require 'rubygems'
require 'agent_xmpp'

AgentXmpp.app_path = 'test/test_client'
AgentXmpp.config_file = 'config/test_client.yml'

##############################################################################################################
class TestClient
  
  ####------------------------------------------------------------------------------------------------------
  class << self
    
    #.........................................................................................................
    attr_accessor :client
    
    #.........................................................................................................
    def command(args)
      iq = Jabber::Iq.new(:set, args[:to])
      iq.query = Jabber::Command::IqCommand.new(args[:node], :execute)
      define_meta_class_method(:did_receive_all_roster_items) do |client_connection|
        client_connection.send(iq) do |r|
          r.to_s
          EventMachine::stop_event_loop
        end
      end
      AgentXmpp::Boot.boot
    end
    
  end
  
#### TestClientManger  
end

##############################################################################################################
$t = TestClient

