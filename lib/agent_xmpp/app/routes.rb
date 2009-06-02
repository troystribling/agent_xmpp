##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Routing
  
    #####-------------------------------------------------------------------------------------------------------
    class Routes

      #.........................................................................................................
      cattr_reader :map
      @@map = Map.new
      #.........................................................................................................

      ####......................................................................................................
      class << self
      
        #.......................................................................................................
        def draw
          yield @@map
        end

        #.......................................................................................................
        def invoke_command_response(connection, params)
          route_path = "#{params[:node]}/#{params[:action]}"
          field_path = fields(params)
          route_path += "/#{field_path}" unless field_path.nil? 
          route = map[route_path]
          unless route.nil?
            begin
              controller_class = eval("#{route[:controller].classify}Controller")
            rescue NameError
              AgentXmpp.logger.error "ROUTING ERROR: #{route[:controller].classify}Controller does not exist for route {:controller => '#{route[:controller]}', :node => '#{params[:node]}', :action => '#{params[:action]}'}."
            else   
              controler_instance = controller_class.new       
              if controler_instance.respond_to?(route[:action])
                controler_instance.handle_request(connection, route[:action], params)
              else
                AgentXmpp.logger.error "ROUTING ERROR: no action on #{controller_class.to_s} for route {:controller => '#{route[:controller]}', :node => '#{params[:node]}', :action => '#{params[:action]}'}."
              end
            end
          else
            AgentXmpp.logger.error "ROUTING ERROR: no route for {:node => '#{params[:node]}', :action => '#{params[:action]}'}."
          end
        end

        #.......................................................................................................
        def invoke_chat_message_body_response(connection, params)
          route = map.chat_message_body_route
          begin
            controller_class = eval("#{route[:controller].classify}Controller")
          rescue ArgumentError
            AgentXmpp.logger.error "ROUTING ERROR: #{params[:node].classify}Controller inavlid for node:#{params[:node]} action:#{params[:action]}."
          else          
            controller_class.new.handle_request(connection, route[:action], params)
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
