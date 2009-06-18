############################################################################################################
class TestXDataController < AgentXmpp::Controller

  #.........................................................................................................
  def scalar
    result_for do
      'scalar' 
    end
    respond_to do |result|
      result.to_x_data
    end
    AgentXmpp.logger.info "ACTION: TestController\#scalar"
  end
 
  #.........................................................................................................
  def hash
    result_for do
      {:attr1 => "val1", :attr2 => "val2"} 
    end
    respond_to do |result|
      result.to_x_data
    end
    AgentXmpp.logger.info "ACTION: TestController\#hash"
  end

  #.........................................................................................................
  def scalar_array
    result_for do
      ['val1', 'val2','val3', 'val4'] 
    end
    respond_to do |result|
      result.to_x_data
    end
    AgentXmpp.logger.info "ACTION: TestController\#array"
  end
 
  #.........................................................................................................
  def hash_array
    result_for do
      [{:attr11 => "val11", :attr12 => "val12"}, {:attr21 => "val21", :attr22 => "val22", :attr23 => "val23"}, {:attr31 => "val31", :attr32 => "val32"}]
    end
    respond_to do |result|
      result.to_x_data
    end
    AgentXmpp.logger.info "ACTION: TestController\#hash_array"
  end
    
############################################################################################################
# TestController
end
