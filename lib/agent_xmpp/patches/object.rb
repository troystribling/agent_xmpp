##############################################################################################################
class Object  

  #.......................................................................................................
  def to_x_data(type='result')
    AgentXmpp::Xmpp::XData.new(type).add_field_with_value(nil, to_s)
  end

  #.......................................................................................................
  def define_meta_class_method(name, &blk)
    (class << self; self; end).instance_eval {define_method(name, &blk)}
  end

#### Object
end
