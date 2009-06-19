##############################################################################################################
AgentXmpp::Routing::Routes.draw do |map|
  
  map.command 'scalar/execute',             :controller => 'test_x_data',      :action => 'scalar'
  map.command 'hash/execute',               :controller => 'test_x_data',      :action => 'hash'
  map.command 'scalar_array/execute',       :controller => 'test_x_data',      :action => 'scalar_array'
  map.command 'hash_array/execute',         :controller => 'test_x_data',      :action => 'hash_array'
  map.command 'array_hash/execute',         :controller => 'test_x_data',      :action => 'array_hash'
  map.command 'array_hash_array/execute',   :controller => 'test_x_data',      :action => 'array_hash_array'
  map.command 'no_action/execute',          :controller => 'test_x_data',      :action => 'no_action'
  map.command 'no_controller/execute',      :controller => 'no_controller',    :action => 'hash_array'
  
end
