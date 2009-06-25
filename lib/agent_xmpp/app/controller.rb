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
      def execute(path, opts = {}, &blk) 
        route(:execute, path, opts, &blk) 
      end

      #.........................................................................................................
      def chat(path, opts = {}, &blk) 
        route(:chat, path, opts, &blk)
      end

      #.........................................................................................................
      def route(action, path, opts={}, &blk)
        (routes[action] ||= []).push({:path => path, :opts => opts, :blk => blk}).last
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
         pipe.error_no_route(params)
       end
     end

     #.......................................................................................................
     def invoke_chat
       route = chat_route
       unless route.nil?
         define_meta_class_method(:request, &route[:blk])
       else
         define_meta_class_method(:request) do
           params[:body].reverse
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

  private
    
    #.........................................................................................................
    def add_payload_to_container(payload)
      meth = "result_#{params[:xmlns].gsub(/:/, "_")}".to_sym
      if pipe.respond_to?(meth) 
        pipe.send_resp(pipe.send_to_method(meth, payload, params)) 
      else
        AgentXmpp.logger.error /
          "PAYLOAD ERROR: unsupported payload {:xmlns => '#{params[:xmlns]}', :node => '#{params[:node]}', :action => '#{params[:action]}'}."
        pipe.error_unsupported_payload(params)
      end
    end
    
    #.........................................................................................................
    def command_route 
      (BaseController.routes[params[:action]] || []).select{|r| r[:path].eql?(params[:node].to_s)}.first
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

