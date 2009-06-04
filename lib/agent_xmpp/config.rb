module AgentXmpp

  VERSION = "0.0.0"
  AGENT_XMPP_NAME = 'AgentXMPP'
  OS_VERSION = IO.popen('uname -sr').readlines.to_s.strip
  @config_file = "config/agent_xmpp.yml"
  @app_path = "."

  class << self
    attr_accessor :config_file, :app_dir
  end
  
end

