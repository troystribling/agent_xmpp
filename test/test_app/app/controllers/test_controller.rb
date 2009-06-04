############################################################################################################
class TestController < AgentXmpp::Controller

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
    
############################################################################################################
# TestController
end
