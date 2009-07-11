# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #.......................................................................................................
    class IqVersion < IqQuery

      #.......................................................................................................
      name_xmlns 'query', 'jabber:iq:version'

      #####-----------------------------------------------------------------------------------------------------
      class << self

        #.........................................................................................................
        def request(pipe, contact_jid)
          iq = Xmpp::Iq.new(:get, contact_jid)
          iq.query = new
          Send(iq) do |r|
            if (r.type == :result) && r.query.kind_of?(Xmpp::IqVersion)
              pipe.broadcast_to_delegates(:did_receive_version_result, pipe, r)
            elsif r.type.eql?(:error)
              pipe.broadcast_to_delegates(:did_receive_version_error, pipe, r)
            end
          end
        end

        #.........................................................................................................
        def result(pipe, request)
          iq = Xmpp::Iq.new(:result, request.from.to_s)
          iq.id = request.id unless request.id.nil?
          iq.query = new
          iq.query.iname = AgentXmpp::AGENT_XMPP_NAME
          iq.query.version = AgentXmpp::VERSION
          iq.query.os = AgentXmpp::OS_VERSION
          Send(iq)
        end

      #### self
      end
      
      #.......................................................................................................
      def initialize(iname=nil, version=nil, os=nil)
        super()
        self.iname = iname if iname
        self.version = version if version
        self.os = os if os
      end

      #.......................................................................................................
      def iname
        first_element_text('name')
      end

      #.......................................................................................................
      def iname=(text)
        replace_element_text('name', text.nil? ? '' : text)
      end

      #.......................................................................................................
      def version
        first_element_text('version')
      end

      #.......................................................................................................
      def version=(text)
        replace_element_text('version', text.nil? ? '' : text)
      end

      #.......................................................................................................
      def os
        first_element_text('os')
      end

      #.......................................................................................................
      def os=(text)
        replace_element_text('os', text.nil? ? '' : text)
      end

    #### IqQueryVersion
    end
    
  #### XMPP
  end

#### AgentXmpp
end
