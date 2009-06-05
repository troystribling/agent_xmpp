##############################################################################################################
AgentXmpp::Routing::Routes.draw do |map|
  
  map.connect 'hash/execute',   :controller => 'test',      :action => 'hash'
  
end
