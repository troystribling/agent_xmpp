require 'rubygems'
require "#{File.dirname(__FILE__)}/../../lib/agent_xmpp"

#.........................................................................................................
execute 'scalar' do
  AgentXmpp.logger.info "ACTION: scalar"
  'scalar' 
end

#.........................................................................................................
execute 'hash' do
  AgentXmpp.logger.info "ACTION: hash"
  {:attr1 => 'val1', :attr2 => 'val2'}
end

#.........................................................................................................
execute 'scalar_array' do
  AgentXmpp.logger.info "ACTION: array"
  ['val1', 'val2','val3', 'val4'] 
end

#.........................................................................................................
execute 'hash_array' do
  AgentXmpp.logger.info "ACTION: hash_array"
  {:attr1 => ['val11', 'val11'], :attr2 => 'val12'}
end

#.........................................................................................................
execute 'array_hash' do
  AgentXmpp.logger.info "ACTION: array_hash"
  [{:attr1 => 'val11', :attr2 => 'val12'}, {:attr1 => 'val21', :attr2 => 'val22'}, {:attr1 => 'val31', :attr2 => 'val32'}]
end

#.........................................................................................................
execute 'array_hash_array' do
  AgentXmpp.logger.info "ACTION: hash_array"
  [{:attr1 => ['val11', 'val11'], :attr2 => 'val12'}, {:attr1 => ['val21', 'val21'], :attr2 => 'val22'}, {:attr1 => ['val31', 'val31'], :attr2 => 'val32'}]
end
