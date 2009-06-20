##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Routing
  
    #####-------------------------------------------------------------------------------------------------------
    class Routes

      #.........................................................................................................
      @map = Map.new
      #.........................................................................................................

      ####......................................................................................................
      class << self
      
        #.........................................................................................................
        attr_reader :map
        #.........................................................................................................

        #.......................................................................................................
        def draw
          yield map
        end

        #.......................................................................................................
        def invoke_command_response(pipe, params)
          route_path = "#{params[:node]}/#{params[:action]}"
          field_path = fields(params)
          route_path += "/#{field_path}" unless field_path.nil? 
          route = map.command_routes[route_path]
          unless route.nil?
            begin
              controller_class = eval("#{route[:controller].classify}Controller")
            rescue NameError
              AgentXmpp.logger.error "ROUTING ERROR: #{route[:controller].classify}Controller does not exist for route {:controller => '#{route[:controller]}', :node => '#{params[:node]}', :action => '#{params[:action]}'}."
              pipe.error_no_route(params)
            else   
              controler_instance = controller_class.new       
              if controler_instance.respond_to?(route[:action])
                controler_instance.handle_request(pipe, route[:action], params)
              else
                AgentXmpp.logger.error "ROUTING ERROR: no action on #{controller_class.to_s} for route {:controller => '#{route[:controller]}', :node => '#{params[:node]}', :action => '#{params[:action]}'}."
                pipe.error_no_route(params)
              end
            end
          else
            AgentXmpp.logger.error "ROUTING ERROR: no route for {:node => '#{params[:node]}', :action => '#{params[:action]}'}."
            pipe.error_no_route(params)
          end
        end

        #.......................................................................................................
        def invoke_chat_response(pipe, params)
          route = map.chat_route
          begin
            controller_class = eval("#{route[:controller].classify}Controller")
          rescue NameError
            AgentXmpp.logger.error "ROUTING ERROR: #{params[:node].classify}Controller inavlid for node:#{params[:node]} action:#{params[:action]}."
            pipe.error_no_route(params)
          else          
            controller_class.new.handle_request(pipe, route[:action], params)
          end
        end
        
        #.......................................................................................................
        def fields(params)
          nil
        end
        
      end
      ####......................................................................................................
      
      #### Routes
      end

  #### Routing
  end
  
#### AgentXmpp
end
