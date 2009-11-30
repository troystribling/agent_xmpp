# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class NoNameXmlnsRegistered < ArgumentError
      def initialize(klass)
        super "Class #{klass} has not set name and xmlns"
      end
    end

    #####-------------------------------------------------------------------------------------------------------
    class ErrorResponse < Element

      #.........................................................................................................
      name_xmlns 'error'
      xmpp_attribute :type, :sym => true

      #####-------------------------------------------------------------------------------------------------------
      class << self
        
        #.........................................................................................................
        def unsupported_payload(params)
          command_error(params, 'bad-request', 'unsupported payload')
        end

        #.........................................................................................................
        def no_route(params)
          command_error(params, 'item-not-found', 'no route for specified command node')
        end

        #.........................................................................................................
        def forbidden(params)
          command_error(params, 'forbidden', 'the requesting JID is not allowed to execute the command')
        end

        #.........................................................................................................
        def feature_not_implemented(request)
          iq_error(request, 'feature-not-implemented', 'feature not implemented')
        end

        #.........................................................................................................
        def service_unavailable(request)
          query_error(request, 'service-unavailable', 'service unavailable')
        end

        #.........................................................................................................
        def item_not_found(request)
          query_error(request, 'item-not-found', 'item not found')
        end

      ####........................................................................................................
      private

        #.........................................................................................................
        def iq_error(request, condition, text)
          iq = Xmpp::Iq.new(:error, request.from)
          iq.id = request.id unless request.id.nil?
          iq.error = Xmpp::ErrorResponse.new(condition, text)
          Send(iq)
        end

        #.........................................................................................................
        def query_error(request, condition, text)
          iq = Xmpp::Iq.new(:error, request.from)
          iq.id = request.id unless request.id.nil?
          iq.query = Xmpp::IqQuery.new
          iq.query.add_namespace(request.query.namespace)
          iq.query.attributes['node'] = request.query.node if request.query.node
          iq.error = Xmpp::ErrorResponse.new(condition, text)
          Send(iq)
        end

        #.........................................................................................................
        def command_error(params, condition, text)
          iq = Xmpp::Iq.new(:error, params[:from])
          iq.id = params[:id] unless params[:id].nil?
          iq.command = Xmpp::IqCommand.new(params[:node], params[:action])
          iq.command = Xmpp::ErrorResponse.new(condition, text)
          Send(iq)
        end
      
      #### self
      end

      #.......................................................................................................
      def initialize(errorcondition=nil, text=nil)
        if errorcondition.nil?
          super()
        else
          errortype = nil
          errorcode = nil
          @@Errors.each do |cond,type,code|
            if errorcondition == cond
              errortype = type
              errorcode = code
            end
          end
          raise ArgumentError, "Unknown error condition when initializing ErrorReponse" if errortype.nil? || errorcode.nil?
          super()
          self.error = errorcondition unless errorcondition.nil?
          self.type = errortype unless errortype.nil?
          self.code = errorcode unless errorcode.nil?
        end
        self.text = text unless text.nil?
      end

      #.......................................................................................................
      def code
        (c = attributes['code']).nil? ? nil : c.to_i
      end

      #.......................................................................................................
      def code=(i)
        attributes['code'] = i.nil? ? nil : i.to_s
      end

      #.......................................................................................................
      def error
        name = nil
        each_element {|e| name = e.name if (e.namespace == 'urn:ietf:params:xml:ns:xmpp-stanzas') && (e.name != 'text') }
        name
      end

      #.......................................................................................................
      def error=(s)
        xe = nil
        each_element {|e| xe = e if (e.namespace == 'urn:ietf:params:xml:ns:xmpp-stanzas') && (e.name != 'text') }
        unless xe.nil?
          delete_element(xe)
        end
        add_element(s).add_namespace('urn:ietf:params:xml:ns:xmpp-stanzas')
      end

      #.......................................................................................................
      def text
        first_element_text('text') || super
      end

      #.......................................................................................................
      def text=(s)
        delete_elements('text')
        unless s.nil?
          e = add_element('text')
          e.add_namespace('urn:ietf:params:xml:ns:xmpp-stanzas')
          e.text = s
        end
      end

      #.......................................................................................................
      @@Errors = [['bad-request', :modify, 400],
                  ['conflict', :cancel, 409],
                  ['feature-not-implemented', :cancel, 501],
                  ['forbidden', :auth, 403],
                  ['gone', :modify, 302],
                  ['internal-server-error', :wait, 500],
                  ['item-not-found', :cancel, 404],
                  ['jid-malformed', :modify, 400],
                  ['not-acceptable', :modify, 406],
                  ['not-allowed', :cancel, 405],
                  ['not-authorized', :auth, 401],
                  ['payment-required', :auth, 402],
                  ['recipient-unavailable', :wait, 404],
                  ['redirect', :modify, 302],
                  ['registration-required', :auth, 407],
                  ['remote-server-not-found', :cancel, 404],
                  ['remote-server-timeout', :wait, 504],
                  ['resource-constraint', :wait, 500],
                  ['service-unavailable', :cancel, 503],
                  ['subscription-required', :auth, 407],
                  ['undefined-condition', nil, 500],
                  ['unexpected-request', :wait, 400]]
                  
    #### ErrorResponse
    end
    
  #### XMPP
  end

#### AgentXmpp
end
