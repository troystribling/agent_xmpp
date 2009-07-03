##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class BaseController

    #---------------------------------------------------------------------------------------------------------
    @routes = {}
    
    #---------------------------------------------------------------------------------------------------------
    class << self
      
      #.........................................................................................................
      attr_reader :routes

      #.........................................................................................................
      def execute(node, opts = {}, &blk) 
        route(:execute, {:node => node, :opts => opts, :blk => blk}) 
      end

      #.........................................................................................................
      def chat(opts = {}, &blk) 
        route(:chat, {:opts => opts, :blk => blk})
      end

      #.........................................................................................................
      def route(action, nroute)
        (routes[action] ||= []).push(nroute).last
      end
     
      #.........................................................................................................
      def command_nodes
        @routes[:execute].map{|r| r[:node]}
      end
      
    #### self
    end

    #.........................................................................................................
    attr_reader :params, :pipe

    #.........................................................................................................
    def initialize(pipe, params)
      @params = params
      @pipe = pipe
    end

    #.......................................................................................................
     def invoke_command
       route = command_route
       unless route.nil?
         define_meta_class_method(:request, &route[:blk])
         define_meta_class_method(:request_callback) do |result|
           add_payload_to_container(result.to_x_data)
         end
         handle_request
       else
         AgentXmpp.logger.error "ROUTING ERROR: no route for {:node => '#{params[:node]}', :action => '#{params[:action]}'}."
         Xmpp::ErrorResponse.no_route(params)
       end
     end

     #.......................................................................................................
     def invoke_chat
       route = chat_route
       unless route.nil?
         define_meta_class_method(:request, &route[:blk])
       else
         define_meta_class_method(:request) do
           "#{AgentXmpp::AGENT_XMPP_NAME} #{AgentXmpp::VERSION}, #{AgentXmpp::OS_VERSION}"
         end
       end
       define_meta_class_method(:request_callback) do |result|
         add_payload_to_container(result)
       end
       handle_request
     end

    #.........................................................................................................
    def handle_request
      EventMachine.defer(method(:request).to_proc, method(:request_callback).to_proc)
    end

    #.........................................................................................................
    # add payloads
    #.........................................................................................................
    def result_jabber_x_data(params, payload)
      Xmpp::IqCommand.result(:to => params[:from], :id => params[:id], :node => params[:node], :payload => payload)
    end

    #.........................................................................................................
    def result_message_chat(params, payload)
      Xmpp::Message.chat(params[:from], payload)
    end
        
  private
    
    #.........................................................................................................
    def add_payload_to_container(payload)
      meth = "result_#{params[:xmlns].gsub(/:/, "_")}".to_sym
      if respond_to?(meth) 
        pipe.send_resp(send(meth, params, payload)) 
      else
        AgentXmpp.logger.error \
          "PAYLOAD ERROR: unsupported payload {:xmlns => '#{params[:xmlns]}', :node => '#{params[:node]}', :action => '#{params[:action]}'}."
        Xmpp::ErrorResponse.unsupported_payload(params)
      end
    end
    
    #.........................................................................................................
    # routes
    #.........................................................................................................
    def command_route 
      (BaseController.routes[params[:action]] || []).select{|r| r[:node].eql?(params[:node].to_s)}.first
    end

    #.........................................................................................................
    def chat_route 
      nil
    end
    
  #### BaseController
  end

  ##############################################################################################################
  class Controller < BaseController

  #### Controller
  end

#### AgentXmpp
end

