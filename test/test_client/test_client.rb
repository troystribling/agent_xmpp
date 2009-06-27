##############################################################################################################
$:.unshift('lib')
require 'rubygems'
require 'agent_xmpp'

#####-------------------------------------------------------------------------------------------------------
AgentXmpp.app_path = 'test/test_client'

##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class Client

    #.........................................................................................................
    def connect
      EventMachine.run do
        @connection = EventMachine.connect(jid.domain, port, Connection, self, jid, password, pipe, port)
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
      msg = AgentXmpp::Xmpp::Message.new(args[:to], args[:body])
      msg.type = :chat
      define_meta_class_method(:did_receive_all_roster_items) do |client_connection|
        client_connection.send(msg)
      end
      AgentXmpp::Boot.boot
    end

    #.........................................................................................................
    def command_x_data(args) 
      iq = AgentXmpp::Xmpp::Iq.new(:set, args[:to])
      iq.query = AgentXmpp::Xmpp::Command::IqCommand.new(args[:node], :execute)
      send_command(iq)
    end

    #.........................................................................................................
    def send_command(iq)
      define_meta_class_method(:did_receive_all_roster_items) do |pipe|
        pipe.send(iq) do |r|
          puts "\nRESPONSE: #{r.to_s}"
        end
      end
      AgentXmpp::Boot.boot
    end
    
  end
  
#### TestClient  
end

#####-------------------------------------------------------------------------------------------------------
$t = TestClient

