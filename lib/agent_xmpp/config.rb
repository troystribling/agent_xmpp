module AgentXmpp

  VERSION = "0.0.0"
  AGENT_XMPP_NAME = 'AgentXMPP'
  OS_VERSION = IO.popen('uname -sr').readlines.to_s.strip
  @config_file = "agent_xmpp.yml"
  @app_path = File.dirname($0)
  
  class << self
    attr_accessor :config_file, :app_path
  end
  
  class AgentXmppError < Exception; end
  
end

