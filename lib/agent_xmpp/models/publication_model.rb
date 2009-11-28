##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class PublicationModel

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      def publications
        @publications ||= AgentXmpp.in_memory_db[:publications]
      end

      #.........................................................................................................
      def load_config
        if AgentXmpp.config['publish'].kind_of?(Array)
          AgentXmpp.config['publish'].each do |pub|
            publications << AgentXmpp::DEFAULT_PUBSUB_CONFIG.inject({}) do |f, (a, v)| 
              f.merge(a => pub[a.to_s] || v)
            end.merge(:status => "new", :node => pub["node"]) 
          end
        end
      end

      #.........................................................................................................
      def find_by_node(node)
        publications[:node => node]
      end

      #.........................................................................................................
      def find_all
        publications.all
      end

      #.........................................................................................................
      def update_status(node, status)
        publications.filter(:node => node).update(:status => status.to_s)
      end

    #### self
    end

  #### PublishModel
  end

#### AgentXmpp
end
