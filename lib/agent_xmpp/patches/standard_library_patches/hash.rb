##############################################################################################################
module AgentXmpp  
  module StandardLibrary
    module HashPatches
    
      ####----------------------------------------------------------------------------------------------------
      module InstanceMethods

        #.......................................................................................................
        def to_x_data(type = 'result')
          inject(Jabber::Dataforms::XData.new(type)) do |data, field| 
            data.add_field_with_value(field.first.to_s, field.last.to_s)
          end
        end

        
      #### InstanceMethods
      end  
        
    #### HashPatches
    end
  ##### StandardLibrary
  end
#### AgentXmpp
end

##############################################################################################################
Hash.send(:include, AgentXmpp::StandardLibrary::HashPatches::InstanceMethods)
