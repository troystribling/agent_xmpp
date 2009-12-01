##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class Service

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      def services
        @services ||= AgentXmpp.in_memory_db[:services]
      end

      #.........................................................................................................
      def service_items
        @service_items ||= AgentXmpp.in_memory_db[:service_items]
      end

      #.........................................................................................................
      def service_features
        @service_features ||= AgentXmpp.in_memory_db[:service_features]
      end

      #.........................................................................................................
      def update(disco_iq)
        disco = disco_iq.query
        case disco
          when AgentXmpp::Xmpp::IqDiscoInfo then update_with_disco_info(disco_iq)
          when AgentXmpp::Xmpp::IqDiscoItems then update_with_disco_items(disco_iq)
        end
      end

      #.........................................................................................................
      def has_jid?(jid)
        services.filter(:jid => jid.to_s).count > 0
      end

      #.........................................................................................................
      def has_disco_info?(jid)
        services.filter(:jid => jid.to_s).count > 0
      end

      #.........................................................................................................
      def has_disco_items?(jid)
        service_items.filter(:service => jid.to_s).count > 0
      end

      #.........................................................................................................
      # private
      #.........................................................................................................
      def update_with_disco_info(disco_iq)
        disco, service = disco_iq.query, disco_iq.from.to_s
        node = disco.node
        disco.identities.each do |i|
          begin
            services << {:node => node, :jid => service, :category => i.category, :type => i.type, :name => i.iname}
          rescue
          end
        end
        disco.features.each do |f|
          begin
            service_features << {:node => node, :service => service, :var => f.var}
          rescue
          end
        end
      end

      #.........................................................................................................
      def update_with_disco_items(disco_iq)
        disco, service = disco_iq.query, disco_iq.from.to_s
        parent_node = disco.node
        disco.items.each do |i|
          begin
            service_items << {:parent_node => parent_node, :service => service, :node => i.node, :jid => i.jid.to_s, :name => i.iname}
          rescue
          end
        end
      end

      #.........................................................................................................
      private :update_with_disco_info, :update_with_disco_items

    #### self
    end

  #### Service
  end

#### AgentXmpp
end
