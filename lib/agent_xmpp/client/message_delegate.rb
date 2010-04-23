##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class MessageDelegate
     
    #####-------------------------------------------------------------------------------------------------------
    class << self
      
      #.........................................................................................................
      attr_reader :pubsub_service
      
      #---------------------------------------------------------------------------------------------------------
      # event flow delegate methods
      #.........................................................................................................
      # process command 
      #.........................................................................................................
      def on_command_set(pipe, stanza)
        command = stanza.command
        params = {:xmlns => 'jabber:x:data', :action => command.action || :execute, :to => stanza.from.to_s, 
                  :from => stanza.from.to_s, :node => command.node, :id => stanza.id, 
                  :sessionid => command.sessionid}
        (data = command.x) ? params.update(:data=>data.to_params, :x_data_type => data.type) : params.update(:data=>{})
        AgentXmpp.logger.info "RECEIVED COMMAND NODE: #{command.node}, FROM: #{stanza.from.to_s}"
        if BaseController.commands_list[params[:sessionid]]
          BaseController.commands_list[params[:sessionid]][:controller].next(params).invoke_command_next
        else
          Controller.new(pipe, params).invoke_command
        end
      end

      #.........................................................................................................
      # process chat messages
      #.........................................................................................................
      def on_message_chat(pipe, stanza)
        params = {:xmlns => 'message:chat', :to => stanza.from.to_s, :from => stanza.from.to_s, 
                  :id => stanza.id, :body => stanza.body}
        AgentXmpp.logger.info "RECEIVED CHAT MESSAGE FROM: #{stanza.from.to_s}"
        Controller.new(pipe, params).invoke_chat
      end

      #.........................................................................................................
      # process normal messages
      #.........................................................................................................
      def on_message_normal(pipe, stanza)
        AgentXmpp.logger.info "RECEIVED NORMAL MESSAGE FROM: #{stanza.from.to_s}"
        if event = stanza.event
          on_pubsub_event(pipe, event, stanza.to.to_s, stanza.from.to_s)
        else
          on_unsupported_message(pipe, stanza)
        end
      end

      #.........................................................................................................
      # process headline messages
      #.........................................................................................................
      def on_message_headline(pipe, stanza)
        AgentXmpp.logger.info "RECEIVED HEADLINE MESSAGE FROM: #{stanza.from.to_s}"
        if event = stanza.event
          on_pubsub_event(pipe, event, stanza.to.to_s, stanza.from.to_s)
        else
          on_unsupported_message(pipe, stanza)
        end
      end
            
      #.........................................................................................................
      # process events
      #.........................................................................................................
      def on_pubsub_event(pipe, event, to, from)
        AgentXmpp.logger.info "RECEIVED EVENT FROM: #{from.to_s}"
        event.items.each do |is|
          src = is.node.split('/')  
          src_jid = "#{src[3]}@#{src[2]}"                
          is.item.each do |i|
            if Message.update_received_event_item(i, from, is.node)
              params = {
                :xmlns => 'http://jabber.org/protocol/pubsub#event', 
                :to => to, :pubsub => from, :node => is.node, :from => src_jid, :id => i.id, 
                :resources => Roster.find_all_by_contact_jid_and_status(Xmpp::Jid.new(src_jid), :available)}
              if data = i.x and data.type.eql?(:result)    
                params.update(:data => data.to_native)
                Controller.new(pipe, params).invoke_event
              elsif entry = i.entry
                params.update(:data => entry.title)
                Controller.new(pipe, params).invoke_event
              else
                on_unsupported_message(pipe, event)
              end
            else
              on_unsupported_message(pipe, event)
            end
          end
        end          
      end
      
      #.........................................................................................................
      # errors
      #.........................................................................................................
      def on_unsupported_message(pipe, stanza)
        AgentXmpp.logger.info "RECEIVED UNSUPPORTED MESSAGE: #{stanza.to_s}"
        if stanza.class.eql?(AgentXmpp::Xmpp::Iq)
          Xmpp::ErrorResponse.feature_not_implemented(stanza)
        end
      end

      #.........................................................................................................
      # connection
      #.........................................................................................................
      def on_connect(pipe)
        AgentXmpp.logger.info "CONNECTED"
      end

      #.........................................................................................................
      def on_disconnect(pipe)
        AgentXmpp.logger.warn "DISCONNECTED"
        EventMachine::stop_event_loop
      end

      #.........................................................................................................
      def on_did_not_connect(pipe)
        AgentXmpp.logger.warn "CONNECTION FAILED"
      end

      #.........................................................................................................
      # authentication
      #.........................................................................................................
      def on_bind(pipe)
        AgentXmpp.logger.info "DID BIND TO RESOURCE: #{AgentXmpp.jid.resource}"
        Xmpp::Iq.session(pipe) if pipe.stream_features.has_key?('session')
      end

      #.........................................................................................................
      def on_preauthenticate_features(pipe)
        AgentXmpp.logger.info "SESSION INITIALIZED"
        Xmpp::SASL.authenticate(pipe.stream_mechanisms)
      end

      #.........................................................................................................
      def on_authenticate(pipe)
        AgentXmpp.logger.info "AUTHENTICATED"
      end

      #.........................................................................................................
      def on_did_not_authenticate(pipe)
        AgentXmpp.logger.info "AUTHENTICATION FAILED"
        raise AgentXmppError, "authentication failed"
      end

      #.........................................................................................................
      def on_postauthenticate_features(pipe)
        AgentXmpp.logger.info "SESSION STARTED"
        Xmpp::Iq.bind(pipe) if pipe.stream_features.has_key?('bind')
      end
 
      #.........................................................................................................
      def on_start_session(pipe)
        AgentXmpp.logger.info "SESSION STARTED"
        add_send_command_request_method(pipe)
        add_send_chat_method(pipe)
        [Send(Xmpp::Presence.new(nil, nil, AgentXmpp.priority)), Xmpp::IqRoster.get(pipe),  
              Xmpp::IqDiscoInfo.get(pipe, AgentXmpp.jid.domain)]
      end

      #.........................................................................................................
      # presence
      #.........................................................................................................
      def on_presence(pipe, presence)
        from_jid = presence.from    
        if Contact.has_jid?(presence.from) or AgentXmpp.is_account_jid?(from_jid) 
          Roster.update(presence)
          AgentXmpp.logger.info "RECEIVED PRESENCE FROM: #{from_jid.to_s}"
          response = []
          unless from_jid.to_s.eql?(AgentXmpp.jid.to_s)
            Boot.call_if_implemented(:call_received_presence, from_jid.to_s, :available)   
            response << Xmpp::IqVersion.get(pipe, from_jid) unless Roster.has_version?(from_jid)
            unless Service.has_jid?(from_jid)
              response << Xmpp::IqDiscoInfo.get(pipe, from_jid)
              response << Xmpp::IqDiscoItems.get(pipe, from_jid, 'http://jabber.org/protocol/commands')
            end
          end; response
        else
          AgentXmpp.logger.warn "RECEIVED PRESENCE FROM JID NOT IN ROSTER: #{from_jid}" unless from_jid.to_s.eql?(AgentXmpp.jid.to_s)
        end
      end

      #.........................................................................................................
      def on_presence_subscribe(pipe, presence)
        from_jid = presence.from.to_s     
        if Contact.has_jid?(presence.from)
          AgentXmpp.logger.info "RECEIVED SUBSCRIBE REQUEST: #{from_jid}"
          Xmpp::Presence.accept(from_jid)  
        else
          AgentXmpp.logger.warn "RECEIVED SUBSCRIBE REQUEST FROM JID NOT IN ROSTER: #{from_jid}"        
          Xmpp::Presence.decline(from_jid)  
        end
      end
      
      #.........................................................................................................
      def on_presence_subscribed(pipe, presence)
        AgentXmpp.logger.info "SUBSCRIPTION ACCEPTED: #{presence.from.to_s}" 
      end
      
      #.........................................................................................................
      def on_presence_unavailable(pipe, presence)
        from_jid = presence.from    
        if Contact.has_jid?(from_jid) or AgentXmpp.is_account_jid?(from_jid) 
          Roster.update(presence)
          Boot.call_if_implemented(:call_received_presence, from_jid.to_s, :unavailable)             
          AgentXmpp.logger.info "RECEIVED UNAVAILABLE PRESENCE FROM: #{from_jid.to_s }"
        else
          AgentXmpp.logger.warn "RECEIVED UNAVAILABLE PRESENCE FROM JID NOT IN ROSTER: #{from_jid}"   
        end
      end
      
      #.........................................................................................................
      def on_presence_unsubscribed(pipe, presence)
        from_jid = presence.from     
        if Contact.has_jid?(from_jid)
          Contact.destroy_by_jid(from_jid)           
          AgentXmpp.logger.info "RECEIVED UNSUBSCRIBED REQUEST: #{from_jid.to_s}"
          Xmpp::IqRoster.remove(pipe, from_jid)  
        else
          AgentXmpp.logger.warn "RECEIVED UNSUBSCRIBED REQUEST FROM JID NOT IN ROSTER: #{from_jid.to_s}"   
        end
      end

      #.........................................................................................................
      def on_presence_error(pipe, presence)
        from_jid = presence.from     
        AgentXmpp.logger.warn "RECEIVED PRESENCE ERROR FROM: #{presence.from.to_s}" 
        if Contact.has_jid?(presence.from) or AgentXmpp.is_account_jid?(from_jid)
          AgentXmpp.logger.warn "REMOVING '#{presence.from.to_s}' FROM ROSTER" 
          Xmpp::IqRoster.remove(pipe, from_jid.to_s)
        end
      end
            
      #.........................................................................................................
      # roster management
      #.........................................................................................................
      def on_roster_result(pipe, stanza)
        process_roster_items(pipe, stanza)
      end
      
      #.........................................................................................................
      def on_roster_set(pipe, stanza)
        process_roster_items(pipe, stanza)
      end
      
      #.........................................................................................................
      def on_roster_item(pipe, roster_item)
        roster_item_jid = roster_item.jid
        AgentXmpp.logger.info "RECEIVED ROSTER ITEM: #{roster_item_jid.to_s}"   
        if Contact.has_jid?(roster_item_jid)
          case roster_item.subscription   
          when :none
            if roster_item.ask.eql?(:subscribe)
              AgentXmpp.logger.info "CONTACT SUBSCRIPTION PENDING: #{roster_item_jid.to_s}" 
              roster_item.subscription = :ask  
            else
              AgentXmpp.logger.info "CONTACT ADDED TO ROSTER: #{roster_item_jid.to_s}"   
              roster_item.subscription = :added  
            end
          when :to
            AgentXmpp.logger.info "SUBSCRIBED TO CONTACT PRESENCE: #{roster_item_jid.to_s}"   
          when :from
            AgentXmpp.logger.info "CONTACT SUBSCRIBED TO PRESENCE: #{roster_item_jid.to_s}"   
          when :both    
            AgentXmpp.logger.info "CONTACT SUBSCRIPTION BIDIRECTIONAL: #{roster_item_jid.to_s}"   
          end
          Contact.update_with_roster_item(roster_item)
          check_roster_item_group(pipe, roster_item)
        else
          AgentXmpp.logger.info "REMOVING ROSTER ITEM: #{roster_item_jid.to_s}"   
          Xmpp::IqRoster.remove(pipe, roster_item_jid)  
        end
      end
     
      #.........................................................................................................
      def on_remove_roster_item(pipe, roster_item)
        AgentXmpp.logger.info "REMOVE ROSTER ITEM"   
        roster_item_jid = roster_item.jid
        if Contact.has_jid?(roster_item_jid) 
          AgentXmpp.logger.info "REMOVED ROSTER ITEM: #{roster_item_jid.to_s}"   
          Contact.destroy_by_jid(roster_item_jid) 
        end
      end
      
      #.........................................................................................................
      def on_all_roster_items(pipe)
        AgentXmpp.logger.info "RECEIVED ALL ROSTER ITEMS" 
        Contact.find_all_by_subscription(:new).map do |r|
          AgentXmpp.logger.info "ADDING CONTACT: #{r[:jid]}" 
          [Xmpp::IqRoster.update(pipe, r[:jid], r[:groups].split(/,/)), Xmpp::Presence.subscribe(r[:jid])]  
        end
      end
      
      #.........................................................................................................
      def on_update_roster_item_result(pipe, roster_item_jid)
        AgentXmpp.logger.info "UPDATE ROSTER ITEM ACKNOWLEDEGED FROM: #{roster_item_jid}"                  
      end

      #.........................................................................................................
      def on_update_roster_item_error(pipe, roster_item_jid)
        AgentXmpp.logger.info "UPDATE ROSTER ITEM RECEIVED ERROR REMOVING: #{roster_item_jid}"
      end
      
      #.........................................................................................................
      def on_remove_roster_item_result(pipe, roster_item_jid)
        AgentXmpp.logger.info "REMOVE ROSTER ITEM ACKNOWLEDEGED FROM: #{roster_item_jid}"   
      end
      
      #.........................................................................................................
      def on_remove_roster_item_error(pipe, roster_item_jid)
        AgentXmpp.logger.info "REMOVE ROSTER ITEM RECEIVED ERROR REMOVING: #{roster_item_jid}"
      end
      
      #.........................................................................................................
      # service discovery management
      #.........................................................................................................
      def on_version_result(pipe, version)
        from_jid, query = version.from, version.query
        AgentXmpp.logger.info "RECEIVED VERSION RESULT: #{from_jid.to_s}, #{query.iname}, #{query.version}"
        Roster.update(query, from_jid)
      end
      
      #.........................................................................................................
      def on_version_get(pipe, request)
        from_jid = request.from
        if Contact.has_jid?(from_jid) or AgentXmpp.is_account_jid?(from_jid)
          AgentXmpp.logger.info "RECEIVED VERSION REQUEST: #{request.from.to_s}"
          Xmpp::IqVersion.result(pipe, request)
        else
          AgentXmpp.logger.warn "RECEIVED VERSION REQUEST FROM JID NOT IN ROSTER: #{request.from.to_s}"
          Xmpp::ErrorResponse.service_unavailable(request)
        end
      end
         
      #.........................................................................................................
      def on_version_error(pipe, result)   
        from_jid = result.from
        AgentXmpp.logger.warn "RECEIVED VERSION ERROR FROM: #{from_jid.to_s}"
      end
         
      #.........................................................................................................
      def on_discoinfo_get(pipe, request)   
        from_jid = request.from
        if Contact.has_jid?(from_jid) or AgentXmpp.is_account_jid?(from_jid)
          if request.query.node.nil?
            AgentXmpp.logger.info "RECEIVED DISCO INFO REQUEST FROM: #{from_jid.to_s}"
            Xmpp::IqDiscoInfo.result(pipe, request)
          else
            AgentXmpp.logger.info "RECEIVED DISCO INFO REQUEST FOR UNSUPPORTED NODE FROM: #{from_jid.to_s}"
            Xmpp::ErrorResponse.item_not_found(request)
          end
        else
          AgentXmpp.logger.warn "RECEIVED DISCO INFO REQUEST FROM JID NOT IN ROSTER: #{from_jid.to_s}"
          Xmpp::ErrorResponse.service_unavailable(request)
        end
      end

      #.........................................................................................................
      def on_discoinfo_result(pipe, discoinfo)   
        from_jid = discoinfo.from
        do_discoitems = true
        request = []
        q = discoinfo.query
        AgentXmpp.logger.info "RECEIVED DISCO INFO RESULT FROM: #{from_jid.to_s}" + (q.node.nil? ? '' : ", NODE: #{q.node}")
        Service.update(discoinfo)
        q.identities.each do |i|
          AgentXmpp.logger.info " IDENTITY: NAME:#{i.iname}, CATEGORY:#{i.category}, TYPE:#{i.type}"
          request << case i.category
                       when 'server'        then Xmpp::IqDiscoItems.get(pipe, from_jid.to_s, q.node) 
                       when 'pubsub'        then process_pubsub_discoinfo(i.type, pipe, from_jid, q.node)
                       when 'conference'
                       when 'proxy'
                       when 'directory'
                       when 'client'
                       when 'automation'
                       when 'auth'
                       when 'collaboration'
                       when 'componenet'
                       when 'gateway'
                       when 'hierarchy'
                       when 'headline'
                       when 'store'
                     end
                   end
        q.features.each do |f|
          AgentXmpp.logger.info " FEATURE: #{f}"
        end
        request.smash
      end
      
      #.........................................................................................................
      def on_discoinfo_error(pipe, result)   
        from_jid = result.from
        AgentXmpp.logger.warn "RECEIVED DISCO INFO ERROR FROM: #{from_jid.to_s}, #{result.query.node}"
      end
      
      #.........................................................................................................
      def on_discoitems_get(pipe, request)   
        from_jid = request.from
        if Contact.has_jid?(from_jid) or AgentXmpp.is_account_jid?(from_jid)
          if request.query.node.eql?('http://jabber.org/protocol/commands')
            AgentXmpp.logger.info "RECEIVED COMMAND NODE DISCO ITEMS REQUEST FROM: #{from_jid.to_s}"
            Xmpp::IqDiscoItems.result_command_nodes(pipe, request)
          elsif request.query.node.nil?
            AgentXmpp.logger.info "RECEIVED DISCO ITEMS REQUEST FROM: #{from_jid.to_s}"
            Xmpp::IqDiscoItems.result(pipe, request)
          else
            AgentXmpp.logger.info "RECEIVED DISCO INFO REQUEST FOR UNSUPPORTED NODE FROM: #{from_jid.to_s}"
            Xmpp::ErrorResponse.item_not_found(request)
          end
        else
          AgentXmpp.logger.warn "RECEIVED DISCO ITEMS REQUEST FROM JID NOT IN ROSTER: #{from_jid.to_s}"
          Xmpp::ErrorResponse.service_unavailable(request)
        end
      end
      
      #.........................................................................................................
      def on_discoitems_result(pipe, discoitems)
        from_jid = discoitems.from
        q = discoitems.query
        AgentXmpp.logger.info "RECEIVED DISCO ITEMS RESULT FROM: #{from_jid.to_s}" + (q.node.nil? ? '' : ", NODE: #{q.node}")
        Service.update(discoitems)
        case q.node
          when 'http://jabber.org/protocol/commands' 
            Boot.call_if_implemented(:call_discovered_command_nodes, from_jid.to_s, q.items.map{|i| i.node}) unless q.items.empty?
        else
          msgs = if from_jid.to_s.eql?(pubsub_service.to_s) and q.node.eql?(AgentXmpp.pubsub_root)
                   create_user_pubsub_root(pipe, from_jid, q.items)
                 else ; []; end
          if from_jid.to_s.eql?(pubsub_service.to_s) and q.node.eql?(AgentXmpp.user_pubsub_root)
            msgs += update_publish_nodes(pipe, from_jid, q.items)
          end
          q.items.inject(msgs) do |r,i|
            AgentXmpp.logger.info " ITEM JID: #{i.jid}" + (i.node.nil? ? '' : ", NODE: #{i.node}")
            r << Xmpp::IqDiscoInfo.get(pipe, i.jid, i.node)         
          end
        end
      end
      
      #.........................................................................................................
      def on_discoitems_error(pipe, result)   
        from_jid = result.from
        AgentXmpp.logger.warn "RECEIVED DISCO ITEMS ERROR FROM: #{from_jid.to_s}, #{result.query.node}"
      end
                
      #.........................................................................................................
      # pubsub
      #.........................................................................................................
      def on_publish_result(pipe, result, node)
        AgentXmpp.logger.info "PUBLISH TO NODE ACKNOWLEDEGED: #{node}, #{result.from.to_s}"
      end
      
      #.........................................................................................................
      def on_publish_error(pipe, result, node)
        AgentXmpp.logger.info "ERROR PUBLISING TO NODE: #{node}, #{result.from.to_s}"
      end
        
      #.........................................................................................................
      def on_discovery_of_pupsub_service(pipe, jid)
        AgentXmpp.logger.info "DISCOVERED PUBSUB SERVICE: #{jid}"
        req = [Xmpp::IqPubSub.subscriptions(pipe, jid.to_s)]
        if /#{AgentXmpp.jid.domain}/.match(jid.to_s)
          add_publish_methods(pipe, jid)
          @pubsub_service = jid
           req += [Xmpp::IqDiscoItems.get(pipe, jid.to_s)] + init_remote_services(pipe)
        end; req
      end

      #.........................................................................................................
      def on_discovery_of_pupsub_collection(pipe, jid, node)
        AgentXmpp.logger.info "DISCOVERED PUBSUB COLLECTION: #{jid}, #{node}"
        Xmpp::IqDiscoItems.get(pipe, jid, node) if pubsub_service.eql?(jid)
      end
        
     #.........................................................................................................
      def on_discovery_of_pupsub_leaf(pipe, jid, node)
        AgentXmpp.logger.info "DISCOVERED PUBSUB LEAF: #{jid}, #{node}"        
        if node.eql?(AgentXmpp.pubsub_root) or node.eql?(AgentXmpp.user_pubsub_root)          
          Xmpp::IqDiscoItems.get(pipe, jid, node)
        else
          Boot.call_if_implemented(:call_discovered_pubsub_node, jid, node)
        end
      end

      #.........................................................................................................
      def on_discovery_of_user_pubsub_root(pipe, pubsub, node)
        AgentXmpp.logger.info "DISCOVERED USER PUBSUB ROOT: #{pubsub.to_s}, #{node}"
      end
        
      #.........................................................................................................
      def on_pubsub_subscriptions_result(pipe, result)
        from_jid = result.from.to_s
        AgentXmpp.logger.info "RECEIVED SUBSCRIPTIONS FROM: #{from_jid}"
        app_subs = BaseController.subscriptions(result.from.domain)
        srvr_subs = result.pubsub.subscriptions.map do |s| 
          AgentXmpp.logger.info "SUBSCRIBED TO NODE: #{from_jid}, #{s.node}"
          Subscription.update(s, s.node, from_jid); s.node
        end
        reqs = app_subs.inject([]) do |r,s|
                 unless srvr_subs.include?(s)
                   AgentXmpp.logger.info "SUBSCRIBING TO NODE: #{from_jid}, #{s}"
                   r << Xmpp::IqPubSub.subscribe(pipe, from_jid, s)
                 end; r
               end
        srvr_subs.inject(reqs) do |r,s|
          unless app_subs.include?(s) 
            AgentXmpp.logger.warn "UNSUBSCRIBING FROM NODE: #{from_jid}, #{s}"
            r << Xmpp::IqPubSub.unsubscribe(pipe, from_jid, s)
          end; r
        end       
      end
      
      #.........................................................................................................
      def on_pubsub_subscriptions_error(pipe, result)
        from_jid = result.from
        AgentXmpp.logger.warn "RECEIVED ERROR ON SUBSCRIPTION REQUEST FROM: #{from_jid}"
      end  

      #.........................................................................................................
      def on_pubsub_affiliations_result(pipe, result)
        from_jid = result.from
        AgentXmpp.logger.info "RECEIVED AFFILIATIONS FROM: #{from_jid}"
      end
      
      #.........................................................................................................
      def on_pubsub_affiliations_error(pipe, result)
        from_jid = result.from
        AgentXmpp.logger.info "RECEIVED ERROR ON AFFILIATIONS REQUEST FROM: #{from_jid}"
      end  

      #.........................................................................................................
      def on_pubsub_create_node_result(pipe, result, node) 
        from_jid = result.from
        Publication.update_status(node, :active)
        Boot.call_if_implemented(:call_discovered_pubsub_node, from_jid, node)
        AgentXmpp.logger.info "RECEIVED CREATE NODE RESULT FROM: #{from_jid.to_s}, #{node}"
        if node.eql?(AgentXmpp.user_pubsub_root)
          [on_discovery_of_user_pubsub_root(pipe, from_jid, node), Xmpp::IqDiscoInfo.get(pipe, from_jid.to_s, node)]   
        end
      end   

      #.........................................................................................................
      def on_pubsub_create_node_error(pipe, result, node)   
        from_jid = result.from
        Publication.update_status(node, :error)
        AgentXmpp.logger.info "RECEIVED CREATE NODE ERROR FROM: #{from_jid.to_s}, #{node}"
      end 

      #.........................................................................................................
      def on_pubsub_delete_node_result(pipe, result, node) 
        from_jid = result.from
        AgentXmpp.logger.info "RECEIVED DELETE NODE RESULT FROM: #{from_jid.to_s}, #{node}"
      end   

      #.........................................................................................................
      def on_pubsub_delete_node_error(pipe, result, node)   
        from_jid = result.from
        AgentXmpp.logger.info "RECEIVED DELETE NODE ERROR FROM: #{from_jid.to_s}, #{node}"
      end 

      #.........................................................................................................
      def on_pubsub_subscribe_result(pipe, result, node) 
        from_jid = result.from.to_s
        Subscription.update(result, node, from_jid)
        AgentXmpp.logger.info "RECEIVED SUBSCRIBE RESULT FROM: #{from_jid}, #{node}"
      end

      #.........................................................................................................
      def on_pubsub_subscribe_error(pipe, result, node) 
        from_jid = result.from
        AgentXmpp.logger.warn "RECEIVED SUBSCRIBE ERROR FROM: #{from_jid.to_s}, #{node}"
        on_pubsub_subscribe_error_item_not_found(pipe, result, node) if result.error.error.eql?('item-not-found')
      end

      #.........................................................................................................
      def on_pubsub_subscribe_error_item_not_found(pipe, result, node) 
        from_jid = result.from
        AgentXmpp.logger.warn "RECEIVED SUBSCRIBE ERROR ITEM-NOT-FOUND FROM: #{from_jid.to_s}, #{node}; " +
                              "RETRYING SUBSCRIPTION IN #{AgentXmpp::SUBSCRIBE_RETRY_PERIOD}s"
        EventMachine::Timer.new(AgentXmpp::SUBSCRIBE_RETRY_PERIOD) do
          pipe.send_resp(Xmpp::IqPubSub.subscribe(pipe, from_jid.to_s, node))
        end        
      end
    
      #.........................................................................................................
      def on_pubsub_unsubscribe_result(pipe, result, node) 
        from_jid = result.from
        Subscription.destroy_by_node(node)
        AgentXmpp.logger.info "RECEIVED UNSUBSCRIBE RESULT FROM: #{from_jid.to_s}, #{node}"
      end

      #.........................................................................................................
      def on_pubsub_unsubscribe_error(pipe, result, node) 
        from_jid = result.from
        AgentXmpp.logger.info "RECEIVED UNSUBSCRIBE ERROR FROM: #{from_jid.to_s}, #{node}"
      end
          
      #.........................................................................................................
      # private
      #.........................................................................................................
      def check_roster_item_group(pipe, roster_item)
        roster_item_jid = roster_item.jid
        roster_item_groups = Contact.find_by_jid(roster_item_jid)[:groups].split(/,/).sort
        unless roster_item.groups.sort.eql?(roster_item_groups)
          AgentXmpp.logger.info "CHANGE IN ROSTER ITEM GROUP FOUND UPDATING: #{roster_item_jid.to_s} to '#{roster_item_groups.join(', ')}'"
          Xmpp::IqRoster.update(pipe, roster_item_jid.to_s, roster_item_groups)
        end
      end

      #.........................................................................................................
      def process_pubsub_discoinfo(type, pipe, from, node)
        case type
          when 'service'    then pipe.broadcast_to_delegates(:on_discovery_of_pupsub_service, pipe, from)
          when 'collection' then pipe.broadcast_to_delegates(:on_discovery_of_pupsub_collection, pipe, from, node)
          when 'leaf'       then pipe.broadcast_to_delegates(:on_discovery_of_pupsub_leaf, pipe, from, node)
        end
      end

      #.........................................................................................................
      def process_roster_items(pipe, stanza)
        [stanza.query.inject([]) do |r, i|  
          method =  i.subscription.eql?(:remove) ? :on_remove_roster_item : :on_roster_item
          r.push(pipe.broadcast_to_delegates(method, pipe, i))
        end, pipe.broadcast_to_delegates(:on_all_roster_items, pipe)].smash
      end
    
      #.........................................................................................................
      def add_publish_methods(pipe, pubsub)
        Publication.find_all.each do |pub|
          if pub[:node]
            meth = ("publish_" + pub[:node].gsub(/-/,'_')).to_sym
            unless AgentXmpp.respond_to?(meth)
              AgentXmpp.define_meta_class_method(meth) do |payload| 
                pipe.send_resp(Xmpp::IqPublish.set(pipe, :node => pub[:node], :to => pubsub, :payload => payload.to_x_data))
              end
              AgentXmpp.logger.info "ADDED PUBLISH METHOD FOR NODE: #{pub[:node]}, #{pubsub}"
              Delegator.delegate(AgentXmpp, meth)
            else
              AgentXmpp.logger.warn "PUBLISH METHOD FOR NODE EXISTS: #{pub[:node]}, #{pubsub}"
            end
          else
            AgentXmpp.logger.warn "NODE NOT SPECIFIED FOR PUBSUB PUBLISH CONFIGURATION"
          end
        end
      end
          
      #.........................................................................................................
      def add_send_command_request_method(pipe)
        AgentXmpp.define_meta_class_method(:send_command_request) do |args, &blk| 
          pipe.send_resp(Xmpp::IqCommand.send_command(:to=>args[:to], :node=>args[:node], :iq_type=>:set, 
            :action=>:execute, :payload=>args[:payload], &blk))
        end    
        Delegator.delegate(AgentXmpp, :send_command_request)
        AgentXmpp.logger.info "ADDED SEND_COMMAND_REQUEST METHOD"
      end

      #.........................................................................................................
      def add_send_chat_method(pipe)
        AgentXmpp.define_meta_class_method(:send_chat) do |args| 
          raise ArgmentError ':to and :body are required' unless args[:to] and args[:body]
          message = Xmpp::Message.new(args[:to], args[:body])
          message.type = args[:type] || :chat
          pipe.send_resp(Send(message)) 
        end   
        Delegator.delegate(AgentXmpp, :send_chat)
        AgentXmpp.logger.info "ADDED MESSAGE METHOD"
      end
          
      #.........................................................................................................
      def create_user_pubsub_root(pipe, pubsub, items)
        if (roots = items.select{|i| i.node.eql?(AgentXmpp.user_pubsub_root)}).empty?      
          AgentXmpp.logger.info "USER PUBSUB ROOT NOT FOUND CREATING NODE: #{pubsub.to_s}, #{AgentXmpp.user_pubsub_root}"
          [Xmpp::IqPubSub.create_node(pipe, pubsub.to_s, AgentXmpp.user_pubsub_root)]
        else
          AgentXmpp.logger.info "USER PUBSUB ROOT FOUND: #{pubsub.to_s}, #{AgentXmpp.user_pubsub_root}"
          on_discovery_of_user_pubsub_root(pipe, pubsub, AgentXmpp.user_pubsub_root); [] 
        end       
      end

      #.........................................................................................................
      def update_publish_nodes(pipe, pubsub, items)
        disco_nodes = items.map{|i| i.node}
        config_nodes = Publication.find_all.map{|pub| "#{AgentXmpp.user_pubsub_root}/#{pub[:node]}"}
        updates = disco_nodes.inject([]) do |u,n|
                    unless config_nodes.include?(n) 
                      AgentXmpp.logger.warn "DELETING PUBSUB NODE: #{pubsub.to_s}, #{n}"
                      u << Xmpp::IqPubSubOwner.delete_node(pipe, pubsub.to_s, n)
                    end; u
                  end                          
        config_nodes.inject(updates) do |u,n|
          unless disco_nodes.include?(n) 
            AgentXmpp.logger.info "ADDING PUBSUB NODE: #{pubsub.to_s}, #{n}"
            u << Xmpp::IqPubSub.create_node(pipe, pubsub.to_s, n)
          end; u
        end                          
      end
          
      #.........................................................................................................
      def init_remote_services(pipe)
        (BaseController.event_domains-[AgentXmpp.jid.domain]).map do |d| 
          Xmpp::IqDiscoInfo.get(pipe, d)
        end
      end

      #.........................................................................................................
      private :init_remote_services, :update_publish_nodes, :create_user_pubsub_root, :add_send_chat_method, 
              :add_send_command_request_method, :add_publish_methods, :process_roster_items, :process_pubsub_discoinfo,
              :check_roster_item_group
          
    #### self
    end
     
  #### MessagePipe
  end

#### AgentXmpp
end
