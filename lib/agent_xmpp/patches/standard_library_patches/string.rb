##############################################################################################################
module AgentXmpp  
  module StandardLibrary
    module StringPatches
    
      ####----------------------------------------------------------------------------------------------------
      module InstanceMethods

        #......................................................................................................
        def classify
          split('_').collect{|s| s.capitalize}.join
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
String.send(:include, AgentXmpp::StandardLibrary::StringPatches::InstanceMethods)
