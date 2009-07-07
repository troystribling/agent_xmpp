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
          iq.query.set_iname(AgentXmpp::AGENT_XMPP_NAME).set_version(AgentXmpp::VERSION).set_os(AgentXmpp::OS_VERSION)
          Send(iq)
        end

      #### self
      end
      
      #.......................................................................................................
      def initialize(iname=nil, version=nil, os=nil)
        super()
        set_iname(iname) if iname
        set_version(version) if version
        set_os(os) if os
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
      def set_iname(text)
        self.iname = text
        self
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
      def set_version(text)
        self.version = text
        self
      end

      #.......................................................................................................
      def os
        first_element_text('os')
      end

      #.......................................................................................................
      def os=(text)
        if text
          replace_element_text('os', text)
        else
          delete_elements('os')
        end
      end

      #.......................................................................................................
      def set_os(text)
        self.os = text
        self
      end
      
    #### IqQueryVersion
    end
    
  #### XMPP
  end

#### AgentXmpp
end
