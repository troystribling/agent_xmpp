# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  module PubSub
    NS_PUBSUB = 'http://jabber.org/protocol/pubsub'

    class IqPubSub < XMPPElement
      name_xmlns 'pubsub', NS_PUBSUB
      force_xmlns true
    end

    class IqPubSubOwner < XMPPElement
      name_xmlns 'pubsub', NS_PUBSUB + '#owner'
      force_xmlns true
    end

  end
end
