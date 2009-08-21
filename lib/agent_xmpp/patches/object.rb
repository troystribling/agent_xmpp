##############################################################################################################
module AgentXmpp  
  module CoreLibrary
    module ObjectPatches
    
      ####----------------------------------------------------------------------------------------------------
      module InstanceMethods

        #.......................................................................................................
        def to_x_data(type='result')
          Xmpp::XData.new(type).add_field_with_value(nil, to_s)
        end
  
        #.......................................................................................................
        def define_meta_class_method(name, &blk)
          (class << self; self; end).instance_eval {define_method(name, &blk)}
        end

      #### InstanceMethods
      end  
        
    #### ObjectPatches
    end
  ##### CoreLibrary
  end
#### AgentXmpp
end

##############################################################################################################
Object.send(:include, AgentXmpp::CoreLibrary::ObjectPatches::InstanceMethods)
