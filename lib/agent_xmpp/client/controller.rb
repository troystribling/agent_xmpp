##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class BaseController

    #---------------------------------------------------------------------------------------------------------
    @routes = {}
    @before_filters = {}
    
    #---------------------------------------------------------------------------------------------------------
    class << self
      
      #.........................................................................................................
      attr_reader :routes, :before_filters

      #.........................................................................................................
      # interface
      #.........................................................................................................
      def command(node, opts = {}, &blk) 
        route(:command, {:node => node, :opts => opts, :blk => blk}) 
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
      def before(args=nil, &blk)
        args = {:command => :all, :event => :all, :chat => :all} if args.nil? or args.eql?(:all)
        args.each {|(msg_type, nodes)| add_before_filter(msg_type, {:nodes => nodes, :blk => blk})}
      end

      #.........................................................................................................
      # managment
      #.........................................................................................................
      def route(msg_type, nroute)
        (routes[msg_type] ||= []).push(nroute).last
      end
     
      #.........................................................................................................
      def add_before_filter(msg_type, nodes)
        (before_filters[msg_type] ||= []).push(nodes).last
      end

      #.........................................................................................................
      def command_nodes(jid)
        (routes[:command] ||= []).inject([]) do |n,r| 
          groups, access = Contact.find_by_jid(jid)[:groups], [r[:opts][:access] || []].flatten
          (access.empty? or access.select{|a| groups.include?(a)}.length > 0) ? n << r[:node] : n
        end
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

    #.........................................................................................................
    # process requests
    #.......................................................................................................
     def invoke_command
       route = get_route(:command)
       unless route.nil?
         if apply_before_filters(:command, params[:node])
           define_meta_class_method(:request, &route[:blk])
           define_meta_class_method(:request_handler) do
             command_result(request)  
           end
           define_meta_class_method(:request_callback) do |*result|
             result = result.length.eql?(1)  ? result.first : result  
             add_payload_to_container(result.nil? ? nil : result.to_x_data)
           end
           process_request(route)
         else
           AgentXmpp.logger.error "ACCESS ERROR: before_filter prevented '#{params[:from]}' access {:node => '#{params[:node]}', :action => '#{params[:action]}'}."
           Xmpp::ErrorResponse.forbidden(params)
         end
       else
         AgentXmpp.logger.error "ROUTING ERROR: no route for {:node => '#{params[:node]}', :action => '#{params[:action]}'}."
         Xmpp::ErrorResponse.no_route(params)
       end
     end

     #.......................................................................................................
     def on(action, &blk)
       define_meta_class_method(("on_"+action.to_s).to_sym, &blk)
     end

     #.........................................................................................................
     def command_result(result)
       result_method = ("on_"+(params[:x_data_type] || params[:action]).to_s).to_sym
       if respond_to?(result_method)
         if params[:action].eql?(:execute) and params[:x_data_type].nil?
             form = Xmpp::XData.new('form')
             on_execute(form); form
         elsif params[:action].eql?(:cancel)
             on_cancel; nil
         else
           send(result_method)
         end
       elsif params[:action].eql?(:cancel)
         nil
       else
         result
       end
     end

     #.......................................................................................................
      def invoke_event
        route = get_route(:event)
        unless route.nil?
          define_meta_class_method(:request_handler, &route[:blk])
          process_request(route)
        else
          AgentXmpp.logger.error "ROUTING ERROR: no route for {:node => '#{params[:node]}'}."
        end
      end

     #.......................................................................................................
     def invoke_chat
       route = chat_route
       unless route.nil?
         define_meta_class_method(:request_handler, &route[:blk])
       else
         define_meta_class_method(:request_handler) do
           "#{AgentXmpp::AGENT_XMPP_NAME} #{AgentXmpp::VERSION}, #{AgentXmpp::OS_VERSION}"
         end
       end
       define_meta_class_method(:request_callback) do |result|
         add_payload_to_container(result) if result.kind_of?(String)
       end
       process_request(route)
     end

    #.........................................................................................................
    def process_request(route)
      if route[:opts][:defer]
        EventMachine.defer(method(:request_handler).to_proc, respond_to?(:request_callback) ? method(:request_callback).to_proc : nil)
      else
        respond_to?(:request_callback) ? request_callback(request_handler) : request_handler
      end
    end

    #.........................................................................................................
    # add payloads
    #.........................................................................................................
    def result_jabber_x_data(payload)
      if params[:action].eql?(:cancel)
        Xmpp::IqCommand.result(:to => params[:from], :id => params[:id], :node => params[:node], 
                               :status => 'canceled', :sessionid => params[:sessionid])
      else
        status = payload.type.eql?(:form) ? 'executing' : 'completed'
        Xmpp::IqCommand.result(:to => params[:from], :id => params[:id], :node => params[:node], :payload => payload, 
                               :status => status, :sessionid => params[:sessionid])
      end
    end

    #.........................................................................................................
    def result_message_chat(payload)
      Xmpp::Message.chat(params[:from], payload)
    end
    
    #.........................................................................................................
    # private
    #.........................................................................................................
    def add_payload_to_container(payload)
      meth = "result_#{params[:xmlns].gsub(/:/, "_")}".to_sym
      if respond_to?(meth) 
        pipe.send_resp(send(meth, payload))
      else
        AgentXmpp.logger.error "PAYLOAD ERROR: unsupported payload {:xmlns => '#{params[:xmlns]}', :node => '#{params[:node]}', :action => '#{params[:action]}'}."
        Xmpp::ErrorResponse.unsupported_payload(params)
      end
    end
    
    #.........................................................................................................
    # routes
    #.........................................................................................................
    def get_route(msg_type) 
      (BaseController.routes[msg_type] || []).select{|r| r[:node].eql?(params[:node].to_s)}.first
    end

    #.........................................................................................................
    def chat_route 
      (BaseController.routes[:chat] ||= []).first
    end

    #.........................................................................................................
    # filters
    #.........................................................................................................
    def apply_before_filters(msg_type, node=nil)
      (BaseController.before_filters[msg_type] || []).inject([]) do |fs, f|
        nodes = [f[:nodes]].flatten
        (nodes.include?(node) or nodes.include?(:all)) ? fs << f : fs
      end.inject(true) do |r,f|
        define_meta_class_method(:filter, &f[:blk])
        r and filter
      end
    end
    
    #.........................................................................................................
    private :add_payload_to_container, :get_route, :chat_route
    
  #### BaseController
  end

  ##############################################################################################################
  class Controller < BaseController

  #### Controller
  end

#### AgentXmpp
end

