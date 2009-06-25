##############################################################################################################
module AgentXmpp  
  module StandardLibrary
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
  ##### StandardLibrary
  end
#### AgentXmpp
end

##############################################################################################################
Float.send(:include, AgentXmpp::StandardLibrary::FloatPatches::InstanceMethods)
