##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class MessageModel

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      def messages
        @messages ||= AgentXmpp.agent_xmpp_db[:messages]
      end

      #.........................................................................................................
      def update(stanza)
        case stanza
          when AgentXmpp::Xmpp::Message 
            if stanza.type.eql?(:chat)
              update_with_chat_message(stanza)
            elsif event = stanza.event and items = event.items
              items.each do |is|
                is.each do |i|
                  (event_item =  i.entry || i.x) if i.respond_to?(:entry) and i.respond_to?(:x)
                  update_with_event(stanza, event_item, is.node, i.id) unless event_item.nil? 
                end
              end
            end
          when AgentXmpp::Xmpp::Iq
            if cmd = stanza.command
              if data = cmd.x
                update_with_command_data(stanza, data, cmd.node)
              else
                update_with_command_request(stanza, cmd.node)
              end
            elsif pubsub = stanza.pubsub and pub = pubsub.publish and item = pub.item 
              if data = item.x
                  update_with_published_data(stanza, data, pub.node)
              end
            end
        end                 
      end

      #.........................................................................................................
      def find_by_item_id(item_id)
        messages[:item_id => item_id]        
      end

      #.........................................................................................................
      # private
      #.........................................................................................................
      def update_with_chat_message(stanza)
        from_jid = stanza.from || AgentXmpp.jid 
        messages << {
          :message_text => stanza.body,
          :content_type => 'text',
          :message_type => stanza.type.to_s,
          :to_jid       => stanza.to.to_s,
          :from_jid     => from_jid.to_s,
          :created_at   => Time.now}
      end
 
      #.........................................................................................................
      def update_with_command_request(stanza, node)
        from_jid = stanza.from || AgentXmpp.jid 
        messages << {
          :content_type  => 'command_request',
          :message_type  => stanza.type.to_s,
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
          :message_type  => data.type.to_s,
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
          :message_type  => data.type,
          :to_jid        => stanza.to.to_s,
          :from_jid      => from_jid.to_s,
          :node          => node,
          :created_at   => Time.now}
      end

      #.........................................................................................................
      def update_with_event(stanza, event, node, item_id)
        content_type = event.name
        unless find_by_item_id(item_id)
          from_jid = stanza.from || AgentXmpp.jid 
          messages << {
            :message_text  => event.to_s,
            :content_type  => content_type,
            :message_type  => 'normal',
            :to_jid        => stanza.to.to_s,
            :from_jid      => from_jid.to_s,
            :node          => node,
            :item_id       => item_id,
            :created_at    => Time.now}
        end    
      end
       
      #.........................................................................................................
      private :update_with_chat_message, :update_with_command_data, :update_with_published_data, :update_with_command_request

    #### self
    end

  #### ContactModel
  end

#### AgentXmpp
end
