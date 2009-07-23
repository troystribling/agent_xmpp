##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class MessageDelegate
     
    #####-------------------------------------------------------------------------------------------------------
    class << self
      
      #.........................................................................................................
      attr_accessor :pubsub_service
      
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
          did_receive_pubsub_event(pipe, event, stanza.to, stanza.from)
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
              params = {:xmlns => 'http://jabber.org/protocol/pubsub#event', :to => to, :from => from, 
                :node => is.node, :data => data.to_native}
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
        [Send(Xmpp::Presence.new(nil, nil, 1)), Xmpp::IqRoster.get(pipe), Xmpp::IqDiscoInfo.get(pipe, pipe.jid.domain), 
         Xmpp::IqDiscoInfo.get(pipe, pipe.jid.bare)]
      end

      #.........................................................................................................
      # presence
      #.........................................................................................................
      def did_receive_presence(pipe, presence)
        if pipe.roster.has_jid?(presence.from) 
          from_jid = presence.from    
          pipe.roster.update_resource(presence)
          AgentXmpp.logger.info "RECEIVED PRESENCE FROM: #{from_jid.to_s }"
          response = []
          unless from_jid.to_s.eql?(pipe.jid.to_s)
            response << Xmpp::IqVersion.request(pipe, from_jid) unless pipe.roster.has_version?(from_jid)
            response << Xmpp::IqDiscoInfo.get(pipe, from_jid) unless pipe.services.has_jid?(from_jid)
          end
          response
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
            pipe.roster.update_roster_item(roster_item)
          end
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
        pipe.roster.find_all_by_status(:inactive).collect do |j, r|
          AgentXmpp.logger.info "ADDING CONTACT: #{j}" 
          Xmpp::IqRoster.add(pipe, j)  
        end
      end
      
      #.........................................................................................................
      def did_receive_add_roster_item_result(pipe, result)
        AgentXmpp.logger.info "ADD ROSTER ITEM ACKNOWLEDEGED FROM: #{result.from.to_s}"   
        Xmpp::Presence.subscribe(result.from)       
        end

      #.........................................................................................................
      def did_receive_add_roster_item_error(pipe, roster_item_jid)
        AgentXmpp.logger.info "ADD ROSTER ITEM RECEIVED ERROR REMOVING: #{roster_item_jid}"
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
            if i.category.eql?('pubsub')
              request << pipe.broadcast_to_delegates(:did_discover_pupsub_service, pipe, from_jid) if i.type.eql?('service')
              request << pipe.broadcast_to_delegates(:did_discover_pupsub_collection, pipe, from_jid, q.node) if i.type.eql?('collection')
              if i.type.eql?('leaf')
                do_discoitems = false
                request << pipe.broadcast_to_delegates(:did_discover_pupsub_leaf, pipe, from_jid, q.node)
              end
            end
          end
          q.features.each do |f|
            AgentXmpp.logger.info " FEATURE: #{f}"
          end
          if do_discoitems or q.node.eql?(pipe.pubsub_root) or q.node.eql?(pipe.user_pubsub_node)
            request << Xmpp::IqDiscoItems.get(pipe, from_jid.to_s, q.node) 
          end
          request.smash
        else
          AgentXmpp.logger.warn "RECEIVED DISCO INFO RESULT FROM JID NOT IN ROSTER: #{from_jid.to_s}"
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
        else
          AgentXmpp.logger.warn "RECEIVED DISCO ITEMS FROM JID NOT IN ROSTER: #{from_jid.to_s}"
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
        AgentXmpp.logger.warn "ERROR PUBLISING TO NODE: #{node}, #{result.from.to_s}"
      end
        
      #.........................................................................................................
      def did_discover_pupsub_service(pipe, jid)
        AgentXmpp.logger.warn "DISCOVERED PUBSUB SERVICE: #{jid}"
        add_publish_methods(pipe, jid)
        @pubsub_service = jid
        Xmpp::IqPubSub.subscriptions(pipe, jid)
      end

      #.........................................................................................................
      def did_discover_pupsub_collection(pipe, jid, node)
        AgentXmpp.logger.warn "DISCOVERED PUBSUB COLLECTION: #{jid}, #{node}"
      end
        
     #.........................................................................................................
      def did_discover_pupsub_leaf(pipe, jid, node)
        AgentXmpp.logger.warn "DISCOVERED PUBSUB LEAF: #{jid}, #{node}"
      end

      #.........................................................................................................
      def did_discover_user_pubsub_node(pipe, pubsub, node)
        AgentXmpp.logger.warn "DISCOVERED USER PUBSUB NODE: #{pubsub.to_s}, #{node}"
      end
        
      #.........................................................................................................
      def did_receive_pubsub_subscriptions_result(pipe, result)
        from_jid = result.from.to_s
        AgentXmpp.logger.info "RECEIVED SUBSCRIPTIONS FROM: #{from_jid}"
        app_subs = BaseController.subscriptions
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
            AgentXmpp.logger.info "UNSUBSCRIBING TO NODE: #{from_jid}, #{s}"
            r << Xmpp::IqPubSub.unsubscribe(pipe, from_jid, s)
          end; r
        end       
      end
      
      #.........................................................................................................
      def did_receive_pubsub_subscriptions_error(pipe, result)
        from_jid = result.from
        AgentXmpp.logger.info "RECEIVED ERROR ON SUBSCRIPTION REQUEST FROM: #{from_jid}"
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
        if config_node = pipe.published.find_by_node(node)
          config_node.update_status(:active)
          Boot.call_if_implemented(:call_discovered_publish_nodes, pipe) if pipe.published.all_are_active?
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
      def did_receive_pubsub_configure_node_result(pipe, result, node) 
        from_jid = result.from
        AgentXmpp.logger.info "RECEIVED CONFIGURE NODE RESULT FROM: #{from_jid.to_s}, #{node}"
      end   

      #.........................................................................................................
      def did_receive_pubsub_configure_node_error(pipe, result, node)   
        from_jid = result.from
        AgentXmpp.logger.info "RECEIVED CONFIGURE NODE ERROR FROM: #{from_jid.to_s}, #{node}"
      end 

      #.........................................................................................................
      def did_receive_pubsub_subscribe_result(pipe, result, node) 
        from_jid = result.from
        AgentXmpp.logger.info "RECEIVED SUBSCRIBE RESULT FROM: #{from_jid.to_s}, #{node}"
      end

      #.........................................................................................................
      def did_receive_pubsub_subscribe_error(pipe, result, node) 
        from_jid = result.from
        AgentXmpp.logger.info "RECEIVED SUBSCRIBE ERROR FROM: #{from_jid.to_s}, #{node}"
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
                Xmpp::IqPublish.set(pipe, :node => p.node, :to => pubsub, :payload => payload.to_x_data)
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
                      pipe.published.find_by_node(n).update_status(:active)
                    end; u
                  end                          
        Boot.call_if_implemented(:call_discovered_publish_nodes, pipe) if pipe.published.all_are_active?
        config_nodes.inject(updates) do |u,n|
          unless disco_nodes.include?(n) 
            AgentXmpp.logger.warn "ADDING PUBSUB NODE: #{pubsub.to_s}, #{n}"
            u << Xmpp::IqPubSub.create_node(pipe, pubsub.to_s, n)
          end; u
        end                          
      end
          
    #### self
    end
     
  #### MessagePipe
  end

#### AgentXmpp
end
