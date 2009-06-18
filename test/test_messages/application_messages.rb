##############################################################################################################
module ApplicationMessages

  #####-------------------------------------------------------------------------------------------------------
  class << self
    
    #### received messages    
    #.........................................................................................................
    def recv_command_execute(client, node, from)
      <<-MSG
        <iq from='#{from}' to='#{client.client.jid.to_s}' id='1' type='set'>
          <command node='#{node}' action='execute' xmlns='http://jabber.org/protocol/commands'/>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_namespace_not_specified_execute(client, from)
    end

    #.........................................................................................................
    def recv_namespace_not_supported_execute(client, node, from)
    end

    #### sent messages    
    #.........................................................................................................
    def sent_x_data_scalar_result(client, to)
      <<-MSG
        <iq from='#{client.client.jid.to_s}' to='#{to}' id='1' type='result' xmlns='jabber:client'>
          <command node='scalar' xmlns='http://jabber.org/protocol/commands'>
            <x xmlns='jabber:x:data'>
              <field>
                <value>scalar</value>
              </field>
            </x>
          </command>
        </iq>      
      MSG
    end

    #.........................................................................................................
    def sent_x_data_hash_result(client, to)
    end

    #.........................................................................................................
    def sent_x_data_scalar_array_result(client, to)
    end

    #.........................................................................................................
    def sent_x_data_hash_array_result(client, to)
    end

    #.........................................................................................................
    def sent_routing_error(client, to)
    end
  
    #.........................................................................................................
    def sent_namespace_not_supported_error(client, to)
    end
     
  end
      
end
