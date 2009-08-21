##############################################################################################################
module AgentXmpp  
  module CoreLibrary
    module FloatPatches
    
      ####----------------------------------------------------------------------------------------------------
      module InstanceMethods

        #......................................................................................................
        def precision(p = 3)
          (10.0**p*self).round.to_f/10.0**p
        end
        
      #### InstanceMethods
      end  
        
    #### ArrayPatches
    end
  ##### CoreLibrary
  end
#### AgentXmpp
end

##############################################################################################################
Float.send(:include, AgentXmpp::CoreLibrary::FloatPatches::InstanceMethods)
