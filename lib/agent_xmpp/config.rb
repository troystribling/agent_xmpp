module AgentXmpp

  #.........................................................................................................
  VERSION = "0.0.0"
  AGENT_XMPP_NAME = 'AgentXMPP'
  OS_VERSION = IO.popen('uname -sr').readlines.to_s.strip
  IDENTITY = {:category => 'client', :name => AGENT_XMPP_NAME, :type => 'bot'}
  FEATURES = ['http://jabber.org/protocol/disco#info', 
              'http://jabber.org/protocol/disco#items',
              'jabber:iq:version',
              'jabber:x:data',
              'http://jabber.org/protocol/commands',
              'http://jabber.org/protocol/muc']
  @config_file = "agent_xmpp.yml"
  @app_path = File.dirname($0)
  @log_file = STDOUT
  
  #.........................................................................................................
  class << self
    attr_accessor :config_file, :app_path, :log_file
    def logger; @logger ||= Logger.new(STDOUT); end
    def logger=(logger); @logger = logger; end
  end
  
  #.........................................................................................................
  class AgentXmppError < Exception; end
  
end

