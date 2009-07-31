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
      def did_receive_command_set(pipe, stanza)
        command = stanza.command
        params = {:xmlns => 'jabber:x:data', :action => command.action, :to => stanza.from.to_s, 
          :from => stanza.from.to_s, :node => command.node, :id => stanza.id}
        AgentXmpp.logger.info "RECEIVED COMMAND NODE: #{command.node}, FROM: #{stanza.from.to_s}"
        Controller.new(pipe, params).invoke_execute
      end

      #.........................................................................................................
      # process chat messages
      #.........................................................................................................
      def did_receive_message_chat(pipe, stanza)
        params = {:xmlns => 'message:chat', :to => stanza.from.to_s, :from => stanza.from.to_s, :id => stanza.id, 
          :body => stanza.body}
        AgentXmpp.logger.info "RECEIVED CHAT MESSAGE FROM: #{stanza.from.to_s}"
        Controller.new(pipe, params).invoke_chat
      end

      #.........................................................................................................
      # process normal messages
      #.........................................................................................................
      def did_receive_message_normal(pipe, stanza)
        AgentXmpp.logger.info "RECEIVED NORMAL MESSAGE FROM: #{stanza.from.to_s}"
        if event = stanza.event
          did_receive_pubsub_event(pipe, event, stanza.to.to_s, stanza.from.to_s)
        else
          did_receive_unsupported_message(pipe, stanza)
        end
      end
      
      #.........................................................................................................
      # process events
      #.........................................................................................................
      def did_receive_pubsub_event(pipe, event, to, from)
        AgentXmpp.logger.info "RECEIVED EVENT FROM: #{from.to_s}"
        event.items.each do |is|
          is.item.each do |i|
            if data = i.x and data.type.eql?(:result)    
              src = is.node.split('/')  
              src_jid = "#{src[3]}@#{src[2]}"                
              params = {:xmlns => 'http://jabber.org/protocol/pubsub#event', :to => to, :pubsub => from, 
                :node => is.node, :data => data.to_native, :from => src_jid,
                :resources => pipe.roster.available_resources(Xmpp::Jid.new(src_jid))}
              Controller.new(pipe, params).invoke_event
            else
              did_receive_unsupported_message(pipe, event)
            end
          end
        end          
      end
      
      #.........................................................................................................
      # errors
      #.........................................................................................................
      def did_receive_unsupported_message(pipe, msg)
        AgentXmpp.logger.info "RECEIVED UNSUPPORTED MESSAGE: #{msg.to_s}"
        if msg.class.eql?(AgentXmpp::Xmpp::Iq)
          Xmpp::ErrorResponse.feature_not_implemented(stanza)
        end
      end

      #.........................................................................................................
      # connection
      #.........................................................................................................
      def did_connect(pipe)
        AgentXmpp.logger.info "CONNECTED"
      end

      #.........................................................................................................
      def did_disconnect(pipe)
        AgentXmpp.logger.warn "DISCONNECTED"
        EventMachine::stop_event_loop
      end

      #.........................................................................................................
      def did_not_connect(pipe)
        AgentXmpp.logger.warn "CONNECTION FAILED"
      end

      #.........................................................................................................
      # authentication
      #.........................................................................................................
      def did_bind(pipe)
        AgentXmpp.logger.info "DID BIND TO RESOURCE: #{pipe.jid.resource}"
        Xmpp::Iq.session(pipe) if pipe.stream_features.has_key?('session')
      end

      #.........................................................................................................
      def did_receive_preauthenticate_features(pipe)
        AgentXmpp.logger.info "SESSION INITIALIZED"
        Xmpp::SASL.authenticate(pipe, pipe.stream_mechanisms)
      end

      #.........................................................................................................
      def did_authenticate(pipe)
        AgentXmpp.logger.info "AUTHENTICATED"
      end

      #.........................................................................................................
      def did_not_authenticate(pipe)
        AgentXmpp.logger.info "AUTHENTICATION FAILED"
        raise AgentXmppError, "authentication failed"
      end

      #.........................................................................................................
      def did_receive_postauthenticate_features(pipe)
        AgentXmpp.logger.info "SESSION STARTED"
        Xmpp::Iq.bind(pipe) if pipe.stream_features.has_key?('bind')
      end
 
      #.........................................................................................................
      def did_start_session(pipe)
        AgentXmpp.logger.info "SESSION STARTED"
        config_roster_item = pipe.roster.find_by_jid(pipe.jid)
        [Send(Xmpp::Presence.new(nil, nil, pipe.priority)), Xmpp::IqRoster.get(pipe),  
         Xmpp::IqDiscoInfo.get(pipe, pipe.jid.domain), 
         Xmpp::IqDiscoInfo.get(pipe, pipe.jid.bare)]
      end

      #.........................................................................................................
      # presence
      #.........................................................................................................
      def did_receive_presence(pipe, presence)
        if pipe.roster.has_jid?(presence.from) 
          from_jid = presence.from    
          pipe.roster.update_resource(presence)
          AgentXmpp.logger.info "RECEIVED PRESENCE FROM: #{from_jid.to_s}"
          response = []
          unless from_jid.to_s.eql?(pipe.jid.to_s)
            Boot.call_if_implemented(:call_received_presence, from_jid.to_s, :available)             
            response << Xmpp::IqVersion.request(pipe, from_jid) unless pipe.roster.has_version?(from_jid)
            unless pipe.services.has_jid?(from_jid)
              response << Xmpp::IqDiscoInfo.get(pipe, from_jid)
              response << Xmpp::IqDiscoItems.get(pipe, from_jid, 'http://jabber.org/protocol/commands')
            end
          end; response
        else
          AgentXmpp.logger.warn "RECEIVED PRESENCE FROM JID NOT IN ROSTER: #{from_jid}" 
        end
      end

      #.........................................................................................................
      def did_receive_presence_subscribe(pipe, presence)
        from_jid = presence.from.to_s     
        if pipe.roster.has_jid?(presence.from) 
          AgentXmpp.logger.info "RECEIVED SUBSCRIBE REQUEST: #{from_jid}"
          Xmpp::Presence.accept(from_jid)  
        else
          AgentXmpp.logger.warn "RECEIVED SUBSCRIBE REQUEST FROM JID NOT IN ROSTER: #{from_jid}"        
          Xmpp::Presence.decline(from_jid)  
        end
      end
      
      #.........................................................................................................
      def did_receive_presence_subscribed(pipe, presence)
        AgentXmpp.logger.warn "SUBSCRIPTION ACCEPTED: #{presence.from.to_s}" 
      end
      
      #.........................................................................................................
      def did_receive_presence_unavailable(pipe, presence)
        from_jid = presence.from    
        if pipe.roster.has_jid?(from_jid) 
          pipe.roster.update_resource(presence)
          Boot.call_if_implemented(:call_received_presence, from_jid.to_s, :unavailable)             
          AgentXmpp.logger.info "RECEIVED UNAVAILABLE PRESENCE FROM: #{from_jid.to_s }"
        else
          AgentXmpp.logger.warn "RECEIVED UNAVAILABLE PRESENCE FROM JID NOT IN ROSTER: #{from_jid}"   
        end
      end
      
      #.........................................................................................................
      def did_receive_presence_unsubscribed(pipe, presence)
        from_jid = presence.from.to_s     
        if pipe.roster.destroy_by_jid(presence.from)           
          AgentXmpp.logger.info "RECEIVED UNSUBSCRIBED REQUEST: #{from_jid}"
          Xmpp::IqRoster.remove(pipe, presence.from)  
        else
          AgentXmpp.logger.warn "RECEIVED UNSUBSCRIBED REQUEST FROM JID NOT IN ROSTER: #{from_jid}"   
        end
      end

      #.........................................................................................................
      def did_receive_presence_error(pipe, presence)
        AgentXmpp.logger.warn "RECEIVED PRESENCE ERROR FROM: #{presence.from.to_s}" 
        if pipe.roster.has_jid?(presence.from)
          AgentXmpp.logger.warn "REMOVING '#{presence.from.to_s}' FROM ROSTER" 
          Xmpp::IqRoster.remove(pipe, presence.from.to_s)
        end
      end
            
      #.........................................................................................................
      # roster management
      #.........................................................................................................
      def did_receive_roster_result(pipe, stanza)
        process_roster_items(pipe, stanza)
      end
      
      #.........................................................................................................
      def did_receive_roster_set(pipe, stanza)
        process_roster_items(pipe, stanza)
      end
      
      #.........................................................................................................
      def did_receive_roster_item(pipe, roster_item)
        roster_item_jid = roster_item.jid
        AgentXmpp.logger.info "RECEIVED ROSTER ITEM: #{roster_item_jid.to_s}"   
        if pipe.roster.has_jid?(roster_item_jid) 
          case roster_item.subscription   
          when :none
            if roster_item.ask.eql?(:subscribe)
              AgentXmpp.logger.info "CONTACT SUBSCRIPTION PENDING: #{roster_item_jid.to_s}"   
              pipe.roster.update_status(roster_item_jid, :ask) 
            else
              AgentXmpp.logger.info "CONTACT ADDED TO ROSTER: #{roster_item_jid.to_s}"   
              pipe.roster.update_status(roster_item_jid, :added)
            end
          when :to
            AgentXmpp.logger.info "SUBSCRIBED TO CONTACT PRESENCE: #{roster_item_jid.to_s}"   
            pipe.roster.update_status(roster_item_jid, :to) 
          when :from
            AgentXmpp.logger.info "CONTACT SUBSCRIBED TO PRESENCE: #{roster_item_jid.to_s}"   
            pipe.roster.update_status(roster_item_jid, :from) 
          when :both    
            AgentXmpp.logger.info "CONTACT SUBSCRIPTION BIDIRECTIONAL: #{roster_item_jid.to_s}"   
            pipe.roster.update_status(roster_item_jid, :both) 
          end
          pipe.roster.update_roster_item(roster_item)
          check_roster_item_group(pipe, roster_item)
        else
          AgentXmpp.logger.info "REMOVING ROSTER ITEM: #{roster_item_jid.to_s}"   
          Xmpp::IqRoster.remove(pipe, roster_item_jid)  
        end
      end
     
      #.........................................................................................................
      def did_remove_roster_item(pipe, roster_item)
        AgentXmpp.logger.info "REMOVE ROSTER ITEM"   
        roster_item_jid = roster_item.jid
        if pipe.roster.has_jid?(roster_item_jid) 
          AgentXmpp.logger.info "REMOVED ROSTER ITEM: #{roster_item_jid.to_s}"   
          pipe.roster.destroy_by_jid(roster_item_jid) 
        end
      end
      
      #.........................................................................................................
      def did_receive_all_roster_items(pipe)
        AgentXmpp.logger.info "RECEIVED ALL ROSTER ITEMS"   
        pipe.roster.find_all_by_status(:inactive).map do |r|
          AgentXmpp.logger.info "ADDING CONTACT: #{r.jid}" 
          [Xmpp::IqRoster.update(pipe, r.jid, r.groups), Xmpp::Presence.subscribe(r.jid)]  
        end
      end
      
      #.........................................................................................................
      def did_receive_update_roster_item_result(pipe, result)
        AgentXmpp.logger.info "UPDATE ROSTER ITEM ACKNOWLEDEGED FROM: #{result.from.to_s}"                  
      end

      #.........................................................................................................
      def did_receive_update_roster_item_error(pipe, roster_item_jid)
        AgentXmpp.logger.info "UPDATE ROSTER ITEM RECEIVED ERROR REMOVING: #{roster_item_jid}"
        pipe.roster.destroy_by_jid(Xmpp::Jid.new(roster_item_jid))
      end
      
      #.........................................................................................................
      def did_receive_remove_roster_item_result(pipe, result)
        AgentXmpp.logger.info "REMOVE ROSTER ITEM ACKNOWLEDEGED FROM: #{result.from.to_s}"   
      end
      
      #.........................................................................................................
      def did_receive_remove_roster_item_error(pipe, roster_item_jid)
        AgentXmpp.logger.info "REMOVE ROSTER ITEM RECEIVED ERROR REMOVING: #{roster_item_jid}"
        pipe.roster.destroy_by_jid(Xmpp::Jid.new(roster_item_jid))
      end
      
      #.........................................................................................................
      # service discovery management
      #.........................................................................................................
      def did_receive_version_result(pipe, version)
        version_jid = version.from
        if pipe.roster.has_jid?(version_jid)
          query = version.query
          AgentXmpp.logger.info "RECEIVED VERSION RESULT: #{version_jid.to_s}, #{query.iname}, #{query.version}"
          pipe.roster.update_resource_version(version)
        else
          AgentXmpp.logger.warn "RECEIVED VERSION RESULT FROM JID NOT IN ROSTER: #{from.to_s}"
        end        
      end
      
      #.........................................................................................................
      def did_receive_version_get(pipe, request)
        if pipe.roster.has_jid?(request.from)
          AgentXmpp.logger.info "RECEIVED VERSION REQUEST: #{request.from.to_s}"
          Xmpp::IqVersion.result(pipe, request)
        else
          AgentXmpp.logger.warn "RECEIVED VERSION REQUEST FROM JID NOT IN ROSTER: #{request.from.to_s}"
        end
      end
         
      #.........................................................................................................
      def did_receive_version_error(pipe, discoinfo)   
        from_jid = discoinfo.from
        AgentXmpp.logger.warn "RECEIVED VERSION ERROR FROM: #{from_jid.to_s}"
      end
         
      #.........................................................................................................
      def did_receive_discoinfo_get(pipe, request)   
        from_jid = request.from
        if pipe.roster.has_jid?(from_jid)
          if request.query.node.nil?
            AgentXmpp.logger.info "RECEIVED DISCO INFO REQUEST FROM: #{from_jid.to_s}"
            Xmpp::IqDiscoInfo.result(pipe, request)
          else
            AgentXmpp.logger.info "RECEIVED DISCO INFO REQUEST FOR UNSUPPORTED NODE FROM: #{from_jid.to_s}"
            Xmpp::ErrorResponse.service_unavailable(request)
          end
        else
          AgentXmpp.logger.warn "RECEIVED DISCO INFO REQUEST FROM JID NOT IN ROSTER: #{from_jid.to_s}"
        end
      end

      #.........................................................................................................
      def did_receive_discoinfo_result(pipe, discoinfo)   
        from_jid = discoinfo.from
        do_discoitems = true
        request = []
        if pipe.roster.has_jid?(from_jid) or pipe.services.has_jid?(from_jid)
          q = discoinfo.query
          AgentXmpp.logger.info "RECEIVED DISCO INFO RESULT FROM: #{from_jid.to_s}" + (q.node.nil? ? '' : ", NODE: #{q.node}")
          pipe.services.update_with_discoinfo(discoinfo)
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
        else
          AgentXmpp.logger.warn "RECEIVED DISCO INFO RESULT FROM JID NOT A ROSTER ITEM OR SERVICE: #{from_jid.to_s}"
        end        
      end
      
      #.........................................................................................................
      def did_receive_discoinfo_error(pipe, discoinfo)   
        from_jid = discoinfo.from
        AgentXmpp.logger.warn "RECEIVED DISCO INFO ERROR FROM: #{from_jid.to_s}, #{discoinfo.query.node}"
      end
      
      #.........................................................................................................
      def did_receive_discoitems_get(pipe, request)   
        from_jid = request.from
        if pipe.roster.has_jid?(from_jid)
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
        end
      end
      
      #.........................................................................................................
      def did_receive_discoitems_result(pipe, discoitems)
        from_jid = discoitems.from
        if pipe.roster.has_jid?(from_jid) or pipe.services.has_jid?(from_jid)
          q = discoitems.query
          AgentXmpp.logger.info "RECEIVED DISCO ITEMS RESULT FROM: #{from_jid.to_s}" + (q.node.nil? ? '' : ", NODE: #{q.node}")
          pipe.services.update_with_discoitems(discoitems)
          case q.node
            when 'http://jabber.org/protocol/commands' 
              Boot.call_if_implemented(:call_discovered_command_nodes, from_jid.to_s, q.items.map{|i| i.node}) unless q.items.empty?
          else
            msgs = if from_jid.to_s.eql?(pubsub_service.to_s) and q.node.eql?(pipe.pubsub_root)
                     create_user_pubsub_root(pipe, from_jid, q.items)
                   else ; []; end
            if from_jid.to_s.eql?(pubsub_service.to_s) and q.node.eql?(pipe.user_pubsub_node)
              msgs += update_publish_nodes(pipe, from_jid, q.items)
            end
            q.items.inject(msgs) do |r,i|
              AgentXmpp.logger.info " ITEM JID: #{i.jid}" + (i.node.nil? ? '' : ", NODE: #{i.node}")
              pipe.services.create(i.jid)
              r << Xmpp::IqDiscoInfo.get(pipe, i.jid, i.node)         
            end
          end
        else
          AgentXmpp.logger.warn "RECEIVED DISCO INFO RESULT FROM JID NOT A ROSTER ITEM OR SERVICE: #{from_jid.to_s}"
        end        
      end
      
      #.........................................................................................................
      def did_receive_discoitems_error(pipe, discoinfo)   
        from_jid = discoinfo.from
        AgentXmpp.logger.warn "RECEIVED DISCO ITEMS ERROR FROM: #{from_jid.to_s}, #{discoinfo.query.node}"
      end
                
      #.........................................................................................................
      # pubsub
      #.........................................................................................................
      def did_receive_publish_result(pipe, result, node)
        AgentXmpp.logger.info "PUBLISH TO NODE ACKNOWLEDEGED: #{node}, #{result.from.to_s}"
      end
      
      #.........................................................................................................
      def did_receive_publish_error(pipe, result, node)
        AgentXmpp.logger.info "ERROR PUBLISING TO NODE: #{node}, #{result.from.to_s}"
      end
        
      #.........................................................................................................
      def did_discover_pupsub_service(pipe, jid)
        AgentXmpp.logger.info "DISCOVERED PUBSUB SERVICE: #{jid}"
        req = [Xmpp::IqPubSub.subscriptions(pipe, jid.to_s)]
        unless pubsub_service
          add_publish_methods(pipe, jid)
          @pubsub_service = jid
           req += [Xmpp::IqDiscoItems.get(pipe, jid.to_s)] + init_remote_services(pipe)
        end; req
      end

      #.........................................................................................................
      def did_discover_pupsub_collection(pipe, jid, node)
        AgentXmpp.logger.info "DISCOVERED PUBSUB COLLECTION: #{jid}, #{node}"
        Xmpp::IqDiscoItems.get(pipe, jid, node) if pubsub_service.eql?(jid)
      end
        
     #.........................................................................................................
      def did_discover_pupsub_leaf(pipe, jid, node)
        AgentXmpp.logger.info "DISCOVERED PUBSUB LEAF: #{jid}, #{node}"        
        if node.eql?(pipe.pubsub_root) or node.eql?(pipe.user_pubsub_node)          
          Xmpp::IqDiscoItems.get(pipe, jid, node)
        else
          Boot.call_if_implemented(:call_discovered_pubsub_node, jid, node)
        end
      end

      #.........................................................................................................
      def did_discover_user_pubsub_node(pipe, pubsub, node)
        AgentXmpp.logger.info "DISCOVERED USER PUBSUB NODE: #{pubsub.to_s}, #{node}"
      end
        
      #.........................................................................................................
      def did_receive_pubsub_subscriptions_result(pipe, result)
        from_jid = result.from.to_s
        AgentXmpp.logger.info "RECEIVED SUBSCRIPTIONS FROM: #{from_jid}"
        app_subs = BaseController.subscriptions(result.from.domain)
        srvr_subs = result.pubsub.subscriptions.map do |s| 
          AgentXmpp.logger.info "SUBSCRIBED TO NODE: #{from_jid}, #{s.node}"
          s.node
        end
        reqs = app_subs.inject([]) do |r,s|
                 unless srvr_subs.include?(s)
                   AgentXmpp.logger.info "SUBSCRIBING TO NODE: #{from_jid}, #{s}"
                   r << Xmpp::IqPubSub.subscribe(pipe, from_jid, s)
                 end; r
               end
        srvr_subs.inject(reqs) do |r,s|
          unless app_subs.include?(s) 
            AgentXmpp.logger.warn "UNSUBSCRIBING TO NODE: #{from_jid}, #{s}"
            r << Xmpp::IqPubSub.unsubscribe(pipe, from_jid, s)
          end; r
        end       
      end
      
      #.........................................................................................................
      def did_receive_pubsub_subscriptions_error(pipe, result)
        from_jid = result.from
        AgentXmpp.logger.warn "RECEIVED ERROR ON SUBSCRIPTION REQUEST FROM: #{from_jid}"
      end  

      #.........................................................................................................
      def did_receive_pubsub_affiliations_result(pipe, result)
        from_jid = result.from
        AgentXmpp.logger.info "RECEIVED AFFILIATIONS FROM: #{from_jid}"
      end
      
      #.........................................................................................................
      def did_receive_pubsub_affiliations_error(pipe, result)
        from_jid = result.from
        AgentXmpp.logger.info "RECEIVED ERROR ON AFFILIATIONS REQUEST FROM: #{from_jid}"
      end  

      #.........................................................................................................
      def did_receive_pubsub_create_node_result(pipe, result, node) 
        from_jid = result.from
        AgentXmpp.logger.info "RECEIVED CREATE NODE RESULT FROM: #{from_jid.to_s}, #{node}"
        if pipe.published.update_status(node, :active)
          Boot.call_if_implemented(:call_discovered_all_publish_nodes) if pipe.published.all_are_active?
        end
        if node.eql?(pipe.user_pubsub_node)
          [did_discover_user_pubsub_node(pipe, from_jid, node), Xmpp::IqDiscoInfo.get(pipe, from_jid.to_s, node)]   
        end
      end   

      #.........................................................................................................
      def did_receive_pubsub_create_node_error(pipe, result, node)   
        from_jid = result.from
        AgentXmpp.logger.info "RECEIVED CREATE NODE ERROR FROM: #{from_jid.to_s}, #{node}"
      end 

      #.........................................................................................................
      def did_receive_pubsub_delete_node_result(pipe, result, node) 
        from_jid = result.from
        AgentXmpp.logger.info "RECEIVED DELETE NODE RESULT FROM: #{from_jid.to_s}, #{node}"
      end   

      #.........................................................................................................
      def did_receive_pubsub_delete_node_error(pipe, result, node)   
        from_jid = result.from
        AgentXmpp.logger.info "RECEIVED DELETE NODE ERROR FROM: #{from_jid.to_s}, #{node}"
      end 

      #.........................................................................................................
      def did_receive_pubsub_subscribe_result(pipe, result, node) 
        from_jid = result.from
        AgentXmpp.logger.info "RECEIVED SUBSCRIBE RESULT FROM: #{from_jid.to_s}, #{node}"
      end

      #.........................................................................................................
      def did_receive_pubsub_subscribe_error(pipe, result, node) 
        from_jid = result.from
        AgentXmpp.logger.warn "RECEIVED SUBSCRIBE ERROR FROM: #{from_jid.to_s}, #{node}"
        did_receive_pubsub_subscribe_error_item_not_found(pipe, result, node) if result.error.error.eql?('item-not-found')
      end

      #.........................................................................................................
      def did_receive_pubsub_subscribe_error_item_not_found(pipe, result, node) 
        from_jid = result.from
        AgentXmpp.logger.warn "RECEIVED SUBSCRIBE ERROR ITEM-NOT-FOUND FROM: #{from_jid.to_s}, #{node}; " +
                              "RETRYING SUBSCRIPTION IN #{AgentXmpp::SUBSCRIBE_RETRY_PERIOD}s"
        EventMachine::Timer.new(AgentXmpp::SUBSCRIBE_RETRY_PERIOD) do
          pipe.send_resp(Xmpp::IqPubSub.subscribe(pipe, from_jid.to_s, node))
        end        
      end
    
      #.........................................................................................................
      def did_receive_pubsub_unsubscribe_result(pipe, result, node) 
        from_jid = result.from
        AgentXmpp.logger.info "RECEIVED UNSUBSCRIBE RESULT FROM: #{from_jid.to_s}, #{node}"
      end

      #.........................................................................................................
      def did_receive_pubsub_unsubscribe_error(pipe, result, node) 
        from_jid = result.from
        AgentXmpp.logger.info "RECEIVED UNSUBSCRIBE ERROR FROM: #{from_jid.to_s}, #{node}"
      end
      
    private
    
      #.........................................................................................................
      def check_roster_item_group(pipe, roster_item)
        roster_item_jid = roster_item.jid
        config_roster_item = pipe.roster.find_by_jid(roster_item_jid)
        unless roster_item.groups.sort.eql?(config_roster_item.groups.sort)
          AgentXmpp.logger.info "CHANGE IN ROSTER ITEM GROUP FOUND UPDATING: #{roster_item_jid.to_s} to '#{config_roster_item.groups.join(', ')}'"
          Xmpp::IqRoster.update(pipe, roster_item_jid.to_s, config_roster_item.groups)
        end
      end

      #.........................................................................................................
      def process_pubsub_discoinfo(type, pipe, from, node)
        case type
          when 'service'    then pipe.broadcast_to_delegates(:did_discover_pupsub_service, pipe, from)
          when 'collection' then pipe.broadcast_to_delegates(:did_discover_pupsub_collection, pipe, from, node)
          when 'leaf'       then pipe.broadcast_to_delegates(:did_discover_pupsub_leaf, pipe, from, node)
        end
      end

      #.........................................................................................................
      def process_roster_items(pipe, stanza)
        [stanza.query.inject([]) do |r, i|  
          method =  i.subscription.eql?(:remove) ? :did_remove_roster_item : :did_receive_roster_item
          r.push(pipe.broadcast_to_delegates(method, pipe, i))
        end, pipe.broadcast_to_delegates(:did_receive_all_roster_items, pipe)].smash
      end
    
      #.........................................................................................................
      def add_publish_methods(pipe, pubsub)
        pipe.published.find_all.each do |p|
          if p.node
            meth = ("publish_" + p.node.gsub(/-/,'_')).to_sym
            unless AgentXmpp.respond_to?(meth)
              AgentXmpp.define_meta_class_method(meth) do |payload| 
                pipe.send_resp(Xmpp::IqPublish.set(pipe, :node => p.node, :to => pubsub, :payload => payload.to_x_data))
              end
              AgentXmpp.logger.info "ADDED PUBLISH METHOD FOR NODE: #{p.node}, #{pubsub}"
              Delegator.delegate(AgentXmpp, meth)
            else
              AgentXmpp.logger.warn "PUBLISH METHOD FOR NODE EXISTS: #{p.node}, #{pubsub}"
            end
          else
            AgentXmpp.logger.warn "NODE NOT SPECIFIED FOR PUBSUB PUBLISH CONFIGURATION"
          end
        end
      end
          
      #.........................................................................................................
      def create_user_pubsub_root(pipe, pubsub, items)
        if (roots = items.select{|i| i.node.eql?(pipe.user_pubsub_node)}).empty?      
          AgentXmpp.logger.info "USER PUBSUB ROOT NOT FOUND CREATING NODE: #{pubsub.to_s}, #{pipe.user_pubsub_node}"
          [Xmpp::IqPubSub.create_node(pipe, pubsub.to_s, pipe.user_pubsub_node)]
        else
          AgentXmpp.logger.info "USER PUBSUB ROOT FOUND: #{pubsub.to_s}, #{pipe.user_pubsub_node}"
          did_discover_user_pubsub_node(pipe, pubsub, pipe.user_pubsub_node); [] 
        end       
      end

      #.........................................................................................................
      def update_publish_nodes(pipe, pubsub, items)
        disco_nodes = items.map{|i| i.node}
        config_nodes = pipe.published.find_all.map{|p| "#{pipe.user_pubsub_node}/#{p.node}"}
        updates = disco_nodes.inject([]) do |u,n|
                    unless config_nodes.include?(n) 
                      AgentXmpp.logger.warn "DELETING PUBSUB NODE: #{pubsub.to_s}, #{n}"
                      u << Xmpp::IqPubSubOwner.delete_node(pipe, pubsub.to_s, n)
                    else
                      pipe.published.update_status(n, :active)
                    end; u
                  end                          
        Boot.call_if_implemented(:call_discovered_all_publish_nodes) if pipe.published.all_are_active?
        config_nodes.inject(updates) do |u,n|
          unless disco_nodes.include?(n) 
            AgentXmpp.logger.warn "ADDING PUBSUB NODE: #{pubsub.to_s}, #{n}"
            u << Xmpp::IqPubSub.create_node(pipe, pubsub.to_s, n)
          end; u
        end                          
      end
          
      #.........................................................................................................
      def init_remote_services(pipe)
        (BaseController.event_domains-[pipe.jid.domain]).map do |d| 
          pipe.services.create(d)
          Xmpp::IqDiscoInfo.get(pipe, d)
        end
      end
          
    #### self
    end
     
  #### MessagePipe
  end

#### AgentXmpp
end
