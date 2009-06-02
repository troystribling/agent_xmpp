##############################################################################################################
module AgentXmpp  
  module XMPP4RPatches
    module Iq
  
      ####----------------------------------------------------------------------------------------------------
      module InstanceMethods

        #.....................................................................................................
        def command=(newcommand)
          delete_elements(newcommand.name)
          add(newcommand)
        end
    
      #### InstanceMethods
      end 
       
    ##### Iq
    end
  ##### XMPP4RPatches
  end
#### AgentXmpp
end

##############################################################################################################
Jabber::Iq.send(:include, AgentXmpp::XMPP4RPatches::Iq::InstanceMethods)
