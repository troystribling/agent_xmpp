module AgentXmpp

  #.........................................................................................................
  VERSION = "0.1.1"
  AGENT_XMPP_NAME = 'AgentXMPP'
  OS_VERSION = IO.popen('uname -sr').readlines.first.to_s.strip
  SUBSCRIBE_RETRY_PERIOD = 60
  IDENTITY = {:category => 'client', :name => AGENT_XMPP_NAME, :type => 'bot'}
  FEATURES = ['http://jabber.org/protocol/disco#info', 
              'http://jabber.org/protocol/disco#items',
              'jabber:iq:version',
              'jabber:x:data',
              'http://jabber.org/protocol/commands',
              'http://jabber.org/protocol/pubsub',
              'http://jabber.org/protocol/pubsub#publish',
              'http://jabber.org/protocol/pubsub#subscribe',
              'http://jabber.org/protocol/pubsub#create-nodes',
              'http://jabber.org/protocol/pubsub#delete-nodes']
  GARBAGE_COLLECTION_INTERVAL = 86400
  DEFAULT_PUBSUB_CONFIG = {
    :title                    => 'event',
    :access_model             => 'presence',
    :max_items                => 20,
    :deliver_notifications    => 1,
    :deliver_payloads         => 1,
    :persist_items            => 1,
    :subscribe                => 1,
    :notify_config            => 0,
    :notify_delete            => 0,
    :notify_retract           => 0,
  }

  #.........................................................................................................
  @app_path = File.expand_path(File.dirname($0))
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

