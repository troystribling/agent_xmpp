##############################################################################################################
class Array
  
  #......................................................................................................
  def to_x_data(type = 'result')
    data = AgentXmpp::Xmpp::XData.new(type)
    if first.kind_of?(Hash)
      field_type = lambda{|v| v.kind_of?(Array) ? 'list-multi' : nil}
      reported = AgentXmpp::Xmpp::XDataReported.new
      first.each_key {|var| reported.add_field(var.to_s)}
      data << reported
      each do |fields|
        item = AgentXmpp::Xmpp::XDataItem.new
        fields.each{|var, val| item.add_field_with_value(var.to_s, [val].flatten.collect{|v| v.to_s}, field_type[val])}
        data << item
      end
    else
      field = AgentXmpp::Xmpp::XDataField.new
      field.values = map{|v| v.to_s}
      field.type ='list-multi'
      data << field
    end
    data
  end
  
  #......................................................................................................
  def smash
    self.flatten.compact
  end
        
#### Array
end
