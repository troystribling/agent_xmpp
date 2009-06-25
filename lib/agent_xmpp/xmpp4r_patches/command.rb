##############################################################################################################
module AgentXmpp  
  module XMPP4RPatches
    module Command
  
      ####----------------------------------------------------------------------------------------------------
      module InstanceMethods

        #.....................................................................................................
        def <<(child)
          add(child)
        end

      #### InstanceMethods
      end  
        
    ##### Command
    end
  ##### XMPP4RPatches
  end
#### AgentXmpp
end

##############################################################################################################
Jabber::Command::IqCommand.send(:include, Jabber::XParent)
Jabber::Command::IqCommand.send(:include, AgentXmpp::XMPP4RPatches::Command::InstanceMethods)
