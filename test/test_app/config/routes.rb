##############################################################################################################
AgentXmpp::Routing::Routes.draw do |map|
  
  map.connect 'scalar/execute',        :controller => 'test_x_data',      :action => 'scalar'
  map.connect 'hash/execute',          :controller => 'test_x_data',      :action => 'hash'
  map.connect 'scalar_array/execute',  :controller => 'test_x_data',      :action => 'scalar_array'
  map.connect 'hash_array/execute',    :controller => 'test_x_data',      :action => 'hash_array'
  
end
