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

      #####-------------------------------------------------------------------------------------------------------
      class << self
        
        def unsupported_payload(params)
          error(params, 'bad-request', 'unsupported payload')
        end


        #.........................................................................................................
        def no_route(params)
          error(params, 'item-not-found', 'no route for specified command node')
        end

      ####........................................................................................................
      private

        #.........................................................................................................
        def error(params, condition, text)
          iq = Xmpp::Iq.new(:error, params[:from])
          iq.id = params[:id] unless params[:id].nil?
          iq.command = Xmpp::IqCommand.new(params[:node], params[:action])
          iq.command << Xmpp::ErrorResponse.new(condition, text)
          Send(iq)
        end
      
      #### self
      end

      #####-------------------------------------------------------------------------------------------------------
      name_xmlns 'error'

      #.......................................................................................................
      def initialize(errorcondition=nil, text=nil)
        if errorcondition.nil?
          super()
          set_text(text) unless text.nil?
        else
          errortype = nil
          errorcode = nil
          @@Errors.each { |cond,type,code|
            if errorcondition == cond
              errortype = type
              errorcode = code
            end
          }
          if errortype.nil? || errorcode.nil?
            raise ArgumentError, "Unknown error condition when initializing ErrorReponse"
          end
          super()
          set_error(errorcondition)
          set_type(errortype)
          set_code(errorcode)
          set_text(text) unless text.nil?
        end
      end

      #.......................................................................................................
      def code
        if attributes['code']
          attributes['code'].to_i
        else
          nil
        end
      end

      #.......................................................................................................
      def code=(i)
        if i.nil?
          attributes['code'] = nil
        else
          attributes['code'] = i.to_s
        end
      end

      #.......................................................................................................
      def set_code(i)
        self.code = i
        self
      end

      #.......................................................................................................
      def error
        name = nil
        each_element { |e| name = e.name if (e.namespace == 'urn:ietf:params:xml:ns:xmpp-stanzas') && (e.name != 'text') }
        name
      end

      #.......................................................................................................
      def error=(s)
        xe = nil
        each_element { |e| xe = e if (e.namespace == 'urn:ietf:params:xml:ns:xmpp-stanzas') && (e.name != 'text') }
        unless xe.nil?
          delete_element(xe)
        end
        add_element(s).add_namespace('urn:ietf:params:xml:ns:xmpp-stanzas')
      end

      #.......................................................................................................
      def set_error(s)
        self.error = s
        self
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
      def set_text(s)
        self.text = s
        self
      end

      #.......................................................................................................
      def type
        attributes['type'].to_sym
      end

      #.......................................................................................................
      def type=(t)
        attributes['type'] = t.to_s
      end

      #.......................................................................................................
      def set_type(t)
        self.type = t
        self
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
