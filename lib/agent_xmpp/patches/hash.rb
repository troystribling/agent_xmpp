##############################################################################################################
module AgentXmpp  
  module StandardLibrary
    module HashPatches
    
      ####----------------------------------------------------------------------------------------------------
      module InstanceMethods

        #.......................................................................................................
        def to_x_data(type = 'result')
          field_type = lambda{|v| v.kind_of?(Array) ? 'list-multi' : nil}
          inject(Xmpp::XData.new(type)) do |data, (var, val)| 
            data.add_field_with_value(var, [val].flatten.collect{|v| v.to_s}, field_type[val])
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
