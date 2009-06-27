##############################################################################################################
module AgentXmpp  
  module StandardLibrary
    module HashPatches
    
      ####----------------------------------------------------------------------------------------------------
      module InstanceMethods

        #.......................................................................................................
        def to_x_data(type = 'result')
          inject(Xmpp::XData.new(type)) do |data, field| 
            val = field.last
            data.add_field_with_value(field.first.to_s, val.kind_of?(Array) ? val.collect{|v| v.to_s} : [val.to_s])
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
