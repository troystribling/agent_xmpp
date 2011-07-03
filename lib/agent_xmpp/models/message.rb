##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class Message

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      def messages(renew=false)
        @messages ||= AgentXmpp.agent_xmpp_db[:messages]
      end

      #.........................................................................................................
      def drop
        AgentXmpp.agent_xmpp_db(:messages)
      end

      #.........................................................................................................
      def update(stanza)
        case stanza
          when AgentXmpp::Xmpp::Message 
            if stanza.type.eql?(:chat)
              update_with_chat_message(stanza)
            end
          when AgentXmpp::Xmpp::Iq
            if cmd = stanza.command
              if data = cmd.x
                update_with_command_data(stanza, data, cmd.node)
              else
                update_with_command_request(stanza, cmd.node)
              end
            elsif (pubsub = stanza.pubsub).kind_of?(AgentXmpp::Xmpp::IqPubSub) and pub = pubsub.publish and item = pub.item 
              if data = item.x
                update_with_published_data(stanza, data, pub.node)
              end
            end
        end                 
      end

      #.........................................................................................................
      def update_received_event_item(item, from, node)
        (event_item =  item.entry || item.x) if item.respond_to?(:entry) and item.respond_to?(:x)
        event_item.nil? ? false : update_with_event_item(event_item, from, node, item.id) 
      end

      #.........................................................................................................
      def find_by_item_id(item_id)
        item_id.nil? ? nil : messages[:item_id => item_id]        
      end

      #.........................................................................................................
      def find_all
        messages.all
      end

      #.........................................................................................................
      def count_by_from_jid(from_jid)
      end

      #.........................................................................................................
      def count_by_content_type(content_type)
        messages.filter(:content_type => content_type).count
      end

      #.........................................................................................................
      def stats_by_message_type
        AgentXmpp.agent_xmpp_db['SELECT message_type AS type, count(id) AS count, max(created_at) AS last FROM messages GROUP BY message_type'].all.map do |s|
          {:type=>s[:type], :count=>s[:count], :last=>Time.parse(s[:last]).strftime("%y/%m/%d %H:%M")}
        end        
      end
        
      #.........................................................................................................
      def stats_by_node(node)
        stats = AgentXmpp.agent_xmpp_db["SELECT node, count(id) AS count, max(created_at) AS last FROM messages WHERE node = ?", node].first
        {:node=>node, :count=>stats[:count], :last=>stats[:last].nil? ? 'Never' : Time.parse(stats[:last]).strftime("%y/%m/%d %H:%M")}
      end
                
      #.........................................................................................................
      def stats_by_command_node
        BaseController.command_nodes.map{|n| stats_by_node(n)}        
      end
                
      #.........................................................................................................
      # private
      #.........................................................................................................
      def update_with_chat_message(stanza)
        from_jid = stanza.from || AgentXmpp.jid 
        messages << {
          :message_text => stanza.body,
          :content_type => 'text',
          :message_type => 'chat',
          :to_jid       => stanza.to.to_s,
          :from_jid     => from_jid.to_s,
          :created_at   => Time.now}
      end
 
      #.........................................................................................................
      def update_with_command_request(stanza, node)
        from_jid = stanza.from || AgentXmpp.jid 
        messages << {
          :content_type  => 'command_request',
          :message_type   => 'command',
          :to_jid        => stanza.to.to_s,
          :from_jid      => from_jid.to_s,
          :node          => node,
          :created_at    => Time.now}
      end

      #.........................................................................................................
      def update_with_command_data(stanza, data, node)
        from_jid = stanza.from || AgentXmpp.jid 
        messages << {
          :message_text  => data.to_s,
          :content_type  => 'x',
          :message_type  => 'command',
          :to_jid        => stanza.to.to_s,
          :from_jid      => from_jid.to_s,
          :node          => node,
          :created_at    => Time.now}
      end
 
      #.........................................................................................................
      def update_with_published_data(stanza, data, node)
        from_jid = stanza.from || AgentXmpp.jid 
        messages << {
          :message_text  => data.to_s,
          :content_type  => 'x',
          :message_type  => 'event',
          :to_jid        => stanza.to.to_s,
          :from_jid      => from_jid.to_s,
          :node          => node,
          :created_at    => Time.now}
      end

      #.........................................................................................................
      def update_with_event_item(event_item, from, node, item_id)
        unless find_by_item_id(item_id)
          messages << {
            :message_text  => event_item.to_s,
            :content_type  => event_item.name,
            :message_type  => 'event',
            :to_jid        => AgentXmpp.jid.to_s,
            :from_jid      => from.to_s,
            :node          => node,
            :item_id       => item_id,
            :created_at    => Time.now}; true
        else; false; end    
      end
       
      #.........................................................................................................
      private :update_with_chat_message, :update_with_command_data, :update_with_published_data, :update_with_command_request

    #### self
    end

  #### Message
  end

#### AgentXmpp
end
