############################################################################################################
class TestXDataController < AgentXmpp::Controller

  #.........................................................................................................
  def scalar
    AgentXmpp.logger.info "ACTION: TestController\#scalar"
    result_for do
      'scalar' 
    end
    respond_to do |result|
      result.to_x_data
    end
  end
 
  #.........................................................................................................
  def hash
    AgentXmpp.logger.info "ACTION: TestController\#hash"
    result_for do
      {:attr1 => 'val1', :attr2 => 'val2'}
    end
    respond_to do |result|
      result.to_x_data
    end
  end

  #.........................................................................................................
  def scalar_array
    AgentXmpp.logger.info "ACTION: TestController\#array"
    result_for do
      ['val1', 'val2','val3', 'val4'] 
    end
    respond_to do |result|
      result.to_x_data
    end
  end
 
  #.........................................................................................................
  def hash_array
    AgentXmpp.logger.info "ACTION: TestController\#hash_array"
    result_for do
      {:attr1 => ['val11', 'val11'], :attr2 => 'val12'}
    end
    respond_to do |result|
      result.to_x_data
    end
  end
 
  #.........................................................................................................
  def array_hash
    AgentXmpp.logger.info "ACTION: TestController\#array_hash"
    result_for do
      [{:attr1 => 'val11', :attr2 => 'val12'}, {:attr1 => 'val21', :attr2 => 'val22'}, {:attr1 => 'val31', :attr2 => 'val32'}]
    end
    respond_to do |result|
      result.to_x_data
    end
  end
 
  #.........................................................................................................
  def array_hash_array
    AgentXmpp.logger.info "ACTION: TestController\#hash_array"
    result_for do
      [{:attr1 => ['val11', 'val11'], :attr2 => 'val12'}, {:attr1 => ['val21', 'val21'], :attr2 => 'val22'}, {:attr1 => ['val31', 'val31'], :attr2 => 'val32'}]
    end
    respond_to do |result|
      result.to_x_data
    end
  end
    
############################################################################################################
# TestController
end
