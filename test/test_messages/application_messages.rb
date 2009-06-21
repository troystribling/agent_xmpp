##############################################################################################################
module ApplicationMessages

  #####-------------------------------------------------------------------------------------------------------
  class << self
    
    #### received messages    
    #.........................................................................................................
    def recv_iq_set_command_execute(client, node, from)
      <<-MSG
        <iq from='#{from}' to='#{client.client.jid.to_s}' id='1' type='set'>
          <command node='#{node}' action='execute' xmlns='http://jabber.org/protocol/commands'/>
        </iq>
      MSG
    end

    #.........................................................................................................
    def recv_message_chat(client, from)
      <<-MSG
        <message from='#{from}' to='#{client.client.jid.to_s}' type='chat'>
          <body>fuck you</body>
        </message>
      MSG
    end

    #### sent messages    
    #.........................................................................................................
    def send_iq_result_command_x_data_scalar(client, to)
      <<-MSG
        <iq id='1' to='#{to}' type='result' xmlns='jabber:client'>
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
    def send_iq_result_command_x_data_hash(client, to)
      <<-MSG
        <iq id='1' to='#{to}' type='result' xmlns='jabber:client'>
          <command node='hash' xmlns='http://jabber.org/protocol/commands'>
            <x xmlns='jabber:x:data'>
              <field var='attr1'>
                <value>val1</value>
              </field>
              <field var='attr2'>
                <value>val2</value>
              </field>
            </x>
          </command>
        </iq>
      MSG
     end

    #.........................................................................................................
    def send_iq_result_command_x_data_scalar_array(client, to)
      <<-MSG
        <iq id='1' to='#{to}' type='result' xmlns='jabber:client'>
          <command node='scalar_array' xmlns='http://jabber.org/protocol/commands'>
            <x xmlns='jabber:x:data'>
              <field>
                <value>val1</value>
                <value>val2</value>
                <value>val3</value>
                <value>val4</value>
              </field>
            </x>
          </command>
        </iq>
      MSG
    end

    #.........................................................................................................
    def send_iq_result_command_x_data_hash_array(client, to)
      <<-MSG
        <iq id='1' to='#{to}' type='result' xmlns='jabber:client'>
          <command node='hash_array' xmlns='http://jabber.org/protocol/commands'>
            <x xmlns='jabber:x:data'>
              <field var='attr1'>
                <value>val11</value>
                <value>val11</value>
              </field>
              <field var='attr2'>
                <value>val12</value>
              </field>
            </x>
          </command>
        </iq>
      MSG
     end

    #.........................................................................................................
    def send_iq_result_command_x_data_array_hash(client, to)
      <<-MSG
        <iq id='1' to='#{to}' type='result' xmlns='jabber:client'>
          <command node='array_hash' xmlns='http://jabber.org/protocol/commands'>
            <x xmlns='jabber:x:data'>
              <reported>
                <field var='attr1'/>
                <field var='attr2'/>
              </reported>
              <item>
                <field var='attr1'>
                  <value>val11</value>
                </field>
                <field var='attr2'>
                  <value>val12</value>
                </field>
              </item>
              <item>
                <field var='attr1'>
                  <value>val21</value>
                </field>
                <field var='attr2'>
                  <value>val22</value>
                </field>
              </item>
              <item>
                <field var='attr1'>
                  <value>val31</value>
                </field>
                <field var='attr2'>
                  <value>val32</value>
                </field>
              </item>
            </x>
          </command>
        </iq>
      MSG
     end

     #.........................................................................................................
     def send_iq_result_command_x_data_array_hash_array(client, to)
       <<-MSG
         <iq id='1' to='#{to}' type='result' xmlns='jabber:client'>
           <command node='array_hash_array' xmlns='http://jabber.org/protocol/commands'>
             <x xmlns='jabber:x:data'>
               <reported>
                 <field var='attr1'/>
                 <field var='attr2'/>
               </reported>
               <item>
                 <field var='attr1'>
                   <value>val11</value>
                   <value>val11</value>
                 </field>
                 <field var='attr2'>
                   <value>val12</value>
                 </field>
               </item>
               <item>
                 <field var='attr1'>
                   <value>val21</value>
                   <value>val21</value>
                 </field>
                 <field var='attr2'>
                   <value>val22</value>
                 </field>
               </item>
               <item>
                 <field var='attr1'>
                   <value>val31</value>
                   <value>val31</value>
                 </field>
                 <field var='attr2'>
                   <value>val32</value>
                 </field>
               </item>
             </x>
           </command>
         </iq>
       MSG
      end

    #.........................................................................................................
    def send_error_command_routing(client, node, to)
      <<-MSG
        <iq id='1' to='#{to}' type='error' xmlns='jabber:client'>
          <command node='#{node}' action='execute' xmlns='http://jabber.org/protocol/commands'>
            <error code='404' type='cancel'>
              <item-not-found xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
              <text xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'>no route for specified command node</text>
            </error>
          </command>
        </iq>
      MSG
    end
       
    #.........................................................................................................
    def send_message_chat(client, to)
      <<-MSG
        <message to='#{to}' type='chat' xmlns='jabber:client'>
          <body>uoy kcuf</body>
        </message>
       MSG
    end
       
  end
      
end
