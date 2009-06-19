##############################################################################################################
module AgentXmpp
  module Routing
  
    #####-------------------------------------------------------------------------------------------------------
    class RoutingConnection < Exception; end

    #####-------------------------------------------------------------------------------------------------------
    class Map

      #.........................................................................................................
      attr_reader :chat_route, :command_routes
      #.........................................................................................................

      #.........................................................................................................
      def initialize
        @command_routes = Hash.new
        @chat_route = {:controller => 'chat', :action => 'body'}
      end

      #.........................................................................................................
      def command(path, options = {})
        path.strip!; path.gsub!(/^\//,'')
        path_elements = path.split('/')
        raise AgentXmppError, "Inavild route connection: #{path}." if path_elements.count < 2 
        @command_routes[path] = {:controller => options[:controller] || path_elements[0], :action => options[:action] || path_elements[1]}
      end

      #.........................................................................................................
      def chat_message(route)
        @chat_route = {:controller => route[:controller], :action => route[:action]}
      end
         
    #### Map
    end

  #### Routing
  end
#### AgentXmpp
end
