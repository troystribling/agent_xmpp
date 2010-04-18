##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class BaseController

    #---------------------------------------------------------------------------------------------------------
    @routes = {}
    @before_filters = {}
    @commands = {}
    
    #---------------------------------------------------------------------------------------------------------
    class << self
      
      #.........................................................................................................
      attr_reader :routes, :before_filters, :commands

      #.........................................................................................................
      # application interface
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
      def command_nodes(jid=nil)
        (routes[:command] ||= []).inject([]) do |nodes, route|
          if jid and not AgentXmpp.is_account_jid?(jid)
            groups, access = Contact.find_by_jid(jid)[:groups], [route[:opts][:access] || []].flatten
            (access.empty? or access.any?{|a| groups.include?(a)}) ? nodes << route[:node] : nodes
          else; nodes << route[:node]; end
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
    attr_reader :params, :pipe, :route, :params_list, :submits

    #.........................................................................................................
    def initialize(pipe, params)
      @params, @pipe = params, pipe
      @params_list, @submits = [params], []
    end

    #.........................................................................................................
    def next(params)
      @params = params
      @params_list << params
      self
    end

    #.........................................................................................................
    # internal interface
    #.......................................................................................................
    def invoke_command
      @route = get_route(:command)
      params[:sessionid] ||= Xmpp::IdGenerator.generate_id
      unless route.nil?
        if apply_before_filters(:command, params[:node])
          define_meta_class_method(:request, &route[:blk])
          define_meta_class_method(:request_handler) do           
            run_command(request)  
          end
          define_meta_class_method(:request_callback) do |*resp|
            resp = resp.length.eql?(1)  ? resp.first : resp  
            add_payload_to_container(resp)
          end
          process_request
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
    def invoke_event
      @route = get_route(:event)
      unless route.nil?
        define_meta_class_method(:request, &route[:blk])
        define_meta_class_method(:request_handler) do
          request; delegate_methods.delegate(pipe, self); flush_messages
        end
        process_request
      else
        AgentXmpp.logger.error "ROUTING ERROR: no route for {:node => '#{params[:node]}'}."
      end
    end

    #.......................................................................................................
    def invoke_chat
      @route = chat_route
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
      process_request
    end

    #.......................................................................................................
    def delegate_methods
      @delegate_methods ||= AgentXmpp::Delegate.new
    end

    #.......................................................................................................
    def messages
      @messages ||= []
    end

    #.......................................................................................................
    def flush_messages
      pipe.send_resp(messages); messages.clear
    end

    #.........................................................................................................
    # application interface
    #.......................................................................................................
    def error(err, *args)
      AgentXmpp::Error.new(err, *args)
    end

    #.......................................................................................................
    def on(action, &blk)
      if action.eql?(:submit)
        @submits << blk
      else
        define_meta_class_method(("on_"+action.to_s).to_sym, &blk)
      end
    end

    #.......................................................................................................
    def xmpp_msg(msg)
      messages << msg
    end

    #.......................................................................................................
    def delegate_to(methods)
      delegate_methods.add_delegate_methods(methods); delegate_methods
    end

    #.........................................................................................................
    def command_completed
      Xmpp::IqCommand.send_command(:to=>params[:from], :node=>params[:node], :iq_type=>:result, :status=>:completed, 
                                   :id => params[:id], :sessionid => params[:sessionid])
    end

    #.........................................................................................................
    def command_canceled
      Xmpp::IqCommand.send_command(:to=>params[:from], :node=>params[:node], :status=>:canceled, :id => params[:id], 
                                   :sessionid => params[:sessionid], :iq_type=>:result)
    end

    #.........................................................................................................
    def command_request(args, &blk)
      raise ArgmentError ':to and :node are required' unless args[:to] and args[:node]
      Xmpp::IqCommand.send_command(:to=>args[:to], :node=>args[:node], :iq_type=>:set, :action=>:execute, :payload=>args[:payload], &blk)
    end
          
    #.........................................................................................................
    # private
    #.........................................................................................................
    def run_command(request)
      request_method = ("on_"+(params[:x_data_type] || params[:action]).to_s).to_sym
      if respond_to?(request_method)
        if params[:action].eql?(:execute) and params[:x_data_type].nil?
            form = Xmpp::XData.new('form')
            on_execute(form); form
        elsif params[:action].eql?(:cancel)
            on_cancel
        else
          send(request_method)
        end
      else
        request
      end
      update_command_list
    end
    
    #.........................................................................................................
    def process_request
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
      delegate_methods.delegate(pipe, self)  
      flush_messages
      if params[:action].eql?(:cancel)
        command_canceled
      elsif payload.kind_of?(AgentXmpp::Error)
        payload.responce
      elsif payload.kind_of?(AgentXmpp::Delegate) 
        nil
      elsif payload.kind_of?(AgentXmpp::Response)
        payload
      else
        command_result(payload.nil? ? nil : payload.to_x_data, params[:sessionid])
      end
    end

    #.........................................................................................................
    def result_message_chat(payload)
      Xmpp::Message.chat(params[:from], payload)
    end
    
    #.........................................................................................................
    def add_payload_to_container(payload)
      meth = "result_#{params[:xmlns].gsub(/:/, "_")}".to_sym
      if respond_to?(meth, true) 
        if res = send(meth, payload)
          pipe.send_resp(res)
        end
      else
        AgentXmpp.logger.error "PAYLOAD ERROR: unsupported payload {:xmlns => '#{params[:xmlns]}', :node => '#{params[:node]}', :action => '#{params[:action]}'}."
        Xmpp::ErrorResponse.unsupported_payload(params)
      end
    end
    
    #.........................................................................................................
    # commands
    #.........................................................................................................
    def on_submit
      unless(blk = submits.shift).nil?
        blk.arity.eql?(1) ? blk.call(Xmpp::XData.new('form')) : blk.call
      end
    end

    #.........................................................................................................
    def update_command_list
      if not BaseController.commands[params[:sessionid]] and submits.length > 1
        BaseController.commands[params[:sessionid]] = self
      elsif BaseController.commands[params[:sessionid]] and submits.length.eql?(1)
        BaseController.commands.delete(params[:sessionid])
      end
    end

    #.........................................................................................................
    def command_result(payload, sessionid)
      if payload
        Xmpp::IqCommand.send_command(:to=>params[:from], :node=>params[:node], :status=>payload.type.eql?(:form) ? :executing : :completed, 
                                     :id => params[:id], :sessionid => sessionid, :payload => payload, :iq_type=>:result)
      else
        Xmpp::IqCommand.send_command(:to=>params[:from], :node=>params[:node], :status=> :completed, :id => params[:id], 
                                     :sessionid => sessionid, :iq_type=>:result)
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
    private :add_payload_to_container, :chat_route, :get_route, :result_jabber_x_data, :result_message_chat, 
            :process_request, :command_result
    
  #### BaseController
  end

  ##############################################################################################################
  class Controller < BaseController

  #### Controller
  end

#### AgentXmpp
end

