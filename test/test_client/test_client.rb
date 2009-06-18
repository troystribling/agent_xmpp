$:.unshift('lib')
require 'rubygems'
require 'agent_xmpp'

AgentXmpp.app_path = 'test/test_client'
AgentXmpp.config_file = 'config/test_client.yml'

##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class Client

    #.........................................................................................................
    def connect
      EventMachine.run do
        @connection = EventMachine.connect(jid.domain, port, Connection, self, jid, password, port)
      end
    end
    
  end
end

##############################################################################################################
class TestClient
  
  ####------------------------------------------------------------------------------------------------------
  class << self
    
    #.........................................................................................................
    attr_accessor :client
    
    #.........................................................................................................
    def command_no_xmlns(args) 
      iq = Jabber::Iq.new(:set, args[:to])
      iq.query = Jabber::Command::IqCommand.new(args[:node], :execute)
      send_command(iq)
    end

    #.........................................................................................................
    def command_x_data(args) 
      iq = Jabber::Iq.new(:set, args[:to])
      iq.query = Jabber::Command::IqCommand.new(args[:node], :execute)
      send_command(iq)
    end

    #.........................................................................................................
    def send_command(iq)
      define_meta_class_method(:did_receive_all_roster_items) do |client_connection|
        client_connection.send(iq) do |r|
          puts "COMMAND RESPONSE: #{r.to_s}"
          sleep(2.0)
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

