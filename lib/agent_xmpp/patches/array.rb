##############################################################################################################
module AgentXmpp  
  module StandardLibrary
    module ArrayPatches
    
      ####----------------------------------------------------------------------------------------------------
      module InstanceMethods

        #......................................................................................................
        def to_x_data(type = 'form')
          data = Xmpp::XData.new(type)
          if first.instance_of?(Hash)
            reported = Xmpp::XDataReported.new
            first.each_key {|var| reported.add_field(var.to_s)}
            data << reported
            each do |fields|
              item = Xmpp::XDataItem.new
              fields.each{|var, value| item.add_field_with_value(var.to_s, value.kind_of?(Array) ? value.collect{|v| v.to_s} : [value.to_s])}
              data << item
            end
          else
            field = Xmpp::XDataField.new
            field.values = map{|v| v.to_s}
            data << field
          end
          data
        end
        
        #......................................................................................................
        def smash
          self.flatten.compact
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
Array.send(:include, AgentXmpp::StandardLibrary::ArrayPatches::InstanceMethods)
