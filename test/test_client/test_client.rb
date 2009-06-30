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
        @connection = EventMachine.connect(jid.domain, port, Connection, self)
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
      boot_with do |pipe|
        pipe.send(msg)
      end
    end

    #.........................................................................................................
    def command_x_data(args) 
      iq = AgentXmpp::Xmpp::Iq.new(:set, args[:to])
      iq.query = AgentXmpp::Xmpp::IqCommand.new(args[:node], :execute)
      send_command(iq)
    end
    
    #.........................................................................................................
    def disco_info(args={}) 
      boot_with do |pipe|
        iq = AgentXmpp::Xmpp::IqDiscoInfo.get(args[:to], pipe).message
        pipe.send(iq) do |r|
          puts "\nRESPONSE: #{r.to_s}"
        end
      end
    end

  private
  
    #.........................................................................................................
    def send_command(iq) 
      boot_with do |pipe|
        pipe.send(iq) do |r|
          puts "\nRESPONSE: #{r.to_s}"
        end
      end
    end

    #.........................................................................................................
    def boot_with
      define_meta_class_method(:did_receive_all_roster_items) do |pipe|
        yield pipe
      end
      AgentXmpp::Boot.boot
    end

  end
  
#### TestClient  
end

#####-------------------------------------------------------------------------------------------------------
$t = TestClient

