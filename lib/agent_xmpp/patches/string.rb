##############################################################################################################
module AgentXmpp  
  module CoreLibrary
    module StringPatches
    
      ####----------------------------------------------------------------------------------------------------
      module InstanceMethods

        #......................................................................................................
        def classify
          split('_').collect{|s| s.capitalize}.join
        end

        #......................................................................................................
        def humanize
          gsub(/_/, ' ')
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
String.send(:include, AgentXmpp::CoreLibrary::StringPatches::InstanceMethods)
