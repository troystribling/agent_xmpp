##############################################################################################################
class Hash  

  #.......................................................................................................
  def to_x_data(type = 'result')
    field_type = lambda{|v| v.kind_of?(Array) ? 'list-multi' : nil}
    inject(AgentXmpp::Xmpp::XData.new(type)) do |data, (var, val)| 
      data.add_field_with_value(var, [val].flatten.map{|v| v.to_s}, field_type[val])
    end
  end
        
#### Hash
end
