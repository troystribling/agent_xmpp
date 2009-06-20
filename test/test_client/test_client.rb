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
        @connection = EventMachine.connect(jid.domain, port, Connection, self, jid, password, message_pipe, port)
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
    def message(args) 
      msg = Jabber::Message.new(args[:to], args[:body])
      msg.type = :chat
      define_meta_class_method(:did_receive_all_roster_items) do |client_connection|
        client_connection.send(msg)
      end
      AgentXmpp::Boot.boot
    end

    #.........................................................................................................
    def command_x_data(args) 
      iq = Jabber::Iq.new(:set, args[:to])
      iq.query = Jabber::Command::IqCommand.new(args[:node], :execute)
      send_command(iq)
    end

    #.........................................................................................................
    def send_command(iq)
      define_meta_class_method(:did_receive_all_roster_items) do |pipe|
        pipe.send(iq) do |r|
          puts "RESPONSE: #{r.to_s}"
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

