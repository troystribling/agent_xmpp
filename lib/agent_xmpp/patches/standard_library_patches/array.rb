##############################################################################################################
module AgentXmpp  
  module StandardLibrary
    module ArrayPatches
    
      ####----------------------------------------------------------------------------------------------------
      module InstanceMethods

        #......................................................................................................
        def to_x_data(type = 'result')
          data = Jabber::Dataforms::XData.new(type)
          reported = Jabber::Dataforms::XDataReported.new
          if first.instance_of?(Hash)
            first.each_key {|var| reported.add_field(var.to_s)}
            data << reported
            each do |fields|
              item = Jabber::Dataforms::XDataItem.new
              fields.each {|var, value| item.add_field_with_value(var.to_s, value.to_s)}
              data << item
            end
          else
            field = Jabber::Dataforms::XDataField.new
            field.values = map {|v| v.to_s}
            data << field
          end
          data
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
