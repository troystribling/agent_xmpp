####------------------------------------------------------------------------------------------------------
class ClientManger
  
  @client = AgentXmpp::Client.new(File.open(client_config) {|yf| YAML::load(yf)})
  
  class << self
    attr_accessor :client
  end
  
end

