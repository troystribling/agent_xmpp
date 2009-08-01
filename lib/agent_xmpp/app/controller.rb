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
      def event(jid, node, opts = {}, &blk) 
        j = Xmpp::Jid.new(jid)
        route(:event, {:node => "/home/#{j.domain}/#{j.node}/#{node}", :domain => j.domain, :opts => opts, :blk => blk}) 
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
        (routes[:execute] ||= []).map{|r| r[:node]}
      end

      #.........................................................................................................
      def subscriptions(service)
        (routes[:event] ||= []).inject([]){|s,r| /#{r[:domain]}/.match(service) ? s << r[:node] : s}
      end
      
      #.........................................................................................................
      def event_domains
        (routes[:event] ||= []).map{|r| r[:domain]}.uniq
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
     def invoke_execute
       route = get_route(params[:action])
       unless route.nil?
         define_meta_class_method(:request, &route[:blk])
         define_meta_class_method(:request_callback) do |*result|
           result = result.first if result.length.eql?(1)  
           add_payload_to_container(result.nil? ? nil : result.to_x_data)
         end
         handle_request
       else
         AgentXmpp.logger.error "ROUTING ERROR: no route for {:node => '#{params[:node]}', :action => '#{params[:action]}'}."
         Xmpp::ErrorResponse.no_route(params)
       end
     end

     #.......................................................................................................
      def invoke_event
        route = get_route(:event)
        unless route.nil?
          define_meta_class_method(:request, &route[:blk])
          handle_request
        else
          AgentXmpp.logger.error "ROUTING ERROR: no route for {:node => '#{params[:node]}'}."
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
         add_payload_to_container(result) if result.kind_of?(String)
       end
       handle_request
     end

    #.........................................................................................................
    def handle_request
      EventMachine.defer(method(:request).to_proc, respond_to?(:request_callback) ? method(:request_callback).to_proc : nil)
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
        AgentXmpp.logger.error "PAYLOAD ERROR: unsupported payload {:xmlns => '#{params[:xmlns]}', :node => '#{params[:node]}', :action => '#{params[:action]}'}."
        Xmpp::ErrorResponse.unsupported_payload(params)
      end
    end
    
    #.........................................................................................................
    # routes
    #.........................................................................................................
    def get_route(action) 
      (BaseController.routes[action] || []).select{|r| r[:node].eql?(params[:node].to_s)}.first
    end

    #.........................................................................................................
    def chat_route 
      (BaseController.routes[:chat] ||= []).first
    end
    
  #### BaseController
  end

  ##############################################################################################################
  class Controller < BaseController

  #### Controller
  end

#### AgentXmpp
end

