##############################################################################################################
module AgentXmpp
  module Routing
  
    #####-------------------------------------------------------------------------------------------------------
    class RoutingConnection < Exception; end

    #####-------------------------------------------------------------------------------------------------------
    class Map

      #.........................................................................................................
      attr_reader :chat_message_body_route
      #.........................................................................................................

      #.........................................................................................................
      def initialize
        @routes = Hash.new
        @chat_message_body_route = {:controller => 'chat_message_body', :action => 'body'}
      end

      #.........................................................................................................
      def connect(path, options = {})
        path.strip!; path.gsub!(/^\//,'')
        path_elements = path.split('/')
        raise RoutingConnection, "Inavild route connection: #{path}." if path_elements.count < 2 
        @routes[path] = {:controller => options[:controller] || path_elements[0], :action => options[:action] || path_elements[1]}
      end

      #.........................................................................................................
      def [](path)
        @routes[path]
      end

      #.........................................................................................................
      def connect_chat_message_body(route)
        @chat_message_body_route = {:controller => route[:controller], :action => route[:action]}
      end
         
    #### Map
    end

  #### Routing
  end
#### AgentXmpp
end
