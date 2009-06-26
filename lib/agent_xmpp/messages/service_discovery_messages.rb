##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  module ServiceDiscoveryMessages

    def get_client_version(contact_jid)
      iq = Xmpp::Iq.new(:get, contact_jid)
      iq.query = Xmpp::Version::IqQueryVersion.new
      Send(iq) do |r|
        if (r.type == :result) && r.query.kind_of?(Xmpp::Version::IqQueryVersion)
          broadcast_to_delegates(:did_receive_client_version_result, self, r.from, r.query)
        end
      end
    end

    #.........................................................................................................
    def result_client_version(request)
      iq = Xmpp::Iq.new(:result, request.from.to_s)
      iq.id = request.id unless request.id.nil?
      iq.query = Xmpp::Version::IqQueryVersion.new
      iq.query.set_iname(AgentXmpp::AGENT_XMPP_NAME).set_version(AgentXmpp::VERSION).set_os(AgentXmpp::OS_VERSION)
      Send(iq)
    end
        
  #### ServiceDiscoveryMessages
  end
  
#### AgentXmpp
end
