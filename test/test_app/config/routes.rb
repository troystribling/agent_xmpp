##############################################################################################################
AgentXmpp::Routing::Routes.draw do |map|
  
  #### system commands
  map.connect 'hash/execute',   :controller => 'test',      :action => 'hash'
  
end
