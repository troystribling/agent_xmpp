##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class Delegate

    #####-------------------------------------------------------------------------------------------------------
    class << self
      
      #---------------------------------------------------------------------------------------------------------
      # event flow delegate methods
      #.........................................................................................................
      # process commands
      #.........................................................................................................
      def did_receive_command_set(pipe, stanza)
        command = stanza.command
        params = {:xmlns => 'jabber:x:data', :action => command.action, :to => stanza.from.to_s, 
          :from => stanza.from.to_s, :node => command.node, :id => stanza.id, :fields => {}}
        AgentXmpp.logger.info "RECEIVED COMMAND NODE: #{command.node}, FROM: #{stanza.from.to_s}"
        Controller.new(pipe, params).invoke_command
      end

      #.........................................................................................................
      # process chat messages
      #.........................................................................................................
      def did_receive_message_chat(pipe, stanza)
        params = {:xmlns => 'message:chat', :to => stanza.from.to_s, :from => stanza.from.to_s, :id => stanza.id, \
          :body => stanza.body}
        AgentXmpp.logger.info "RECEIVED MESSAGE BODY: #{stanza.body}"
        Controller.new(pipe, params).invoke_chat
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
        Xmpp::Iq.bind(pipe) if \
          pipe.stream_features.has_key?('bind') and pipe.stream_features.has_key?('session')
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
      def did_acknowledge_add_roster_item(pipe, response)
        AgentXmpp.logger.info "ADD ROSTER ITEM ACKNOWLEDEGED"   
      end

      #.........................................................................................................
      def did_acknowledge_remove_roster_item(pipe, response)
        AgentXmpp.logger.info "REMOVE ROSTER ITEM ACKNOWLEDEGED"   
      end

      #.........................................................................................................
      def did_receive_add_roster_item_error(pipe, roster_item_jid)
        AgentXmpp.logger.info "ADD ROSTER ITEM RECEIVED ERROR REMOVING: #{roster_item_jid}"
        pipe.roster.destroy_by_jid(Xmpp::JID.new(roster_item_jid))
      end

      #.........................................................................................................
      def did_receive_remove_roster_item_error(pipe, roster_item_jid)
        AgentXmpp.logger.info "REMOVE ROSTER ITEM RECEIVED ERROR REMOVING: #{roster_item_jid}"
        pipe.roster.destroy_by_jid(Xmpp::JID.new(roster_item_jid))
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
        if pipe.roster.has_jid?(from_jid) or pipe.services.has_jid?(from_jid)
          AgentXmpp.logger.info "RECEIVED DISCO INFO RESULT FROM: #{from_jid.to_s}"
          pipe.services.update_with_discoinfo(discoinfo)
          discoinfo.query.identities.each do |i|
            AgentXmpp.logger.info " IDENTITY: NAME:#{i.iname}, CATEGORY:#{i.category}, TYPE:#{i.type}"
          end
          discoinfo.query.features.each do |f|
            AgentXmpp.logger.info " FEATURE: #{f}"
          end
          Xmpp::IqDiscoItems.get(pipe, from_jid.to_s)
        else
          AgentXmpp.logger.warn "RECEIVED DISCO INFO RESULT FROM JID NOT IN ROSTER: #{from_jid.to_s}"
        end        
      end

      #.........................................................................................................
      def did_receive_discoinfo_error(pipe, discoinfo)   
        from_jid = discoinfo.from
        AgentXmpp.logger.warn "RECEIVED DISCO INFO ERROR FROM: #{from_jid.to_s}"
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
          AgentXmpp.logger.info "RECEIVED DISCO ITEMS RESULT FROM: #{discoitems.from.to_s}"
          pipe.services.update_with_discoitems(discoitems)
          discoitems.query.items.inject([]) do |r,i|
            AgentXmpp.logger.info " ITEM JID: #{i.jid}"
            pipe.services.create(i.jid)
            r.push(Xmpp::IqDiscoInfo.get(pipe, i.jid, i.node))            
          end
        else
          AgentXmpp.logger.warn "RECEIVED DISCO ITEMS FROM JID NOT IN ROSTER: #{from_jid.to_s}"
        end        
      end

      #.........................................................................................................
      def did_receive_discoitems_error(pipe, discoinfo)   
        from_jid = discoinfo.from
        AgentXmpp.logger.warn "RECEIVED DISCO ITEMS ERROR FROM: #{from_jid.to_s}"
      end
        
      #.........................................................................................................
      # errors
      #.........................................................................................................
      def did_receive_unsupported_message(pipe, stanza)
        AgentXmpp.logger.info "RECEIVED UNSUPPORTED MESSAGE: #{stanza.to_s}"
        if stanza.class.eql?(AgentXmpp::Xmpp::Iq)
          Xmpp::ErrorResponse.feature_not_implemented(stanza)
        end
      end
      
    private
    
      #.........................................................................................................
      def process_roster_items(pipe, stanza)
        [stanza.query.inject([]) do |r, i|  
          method =  i.subscription.eql?(:remove) ? :did_remove_roster_item : :did_receive_roster_item
          r.push(pipe.broadcast_to_delegates(method, pipe, i))
        end, pipe.broadcast_to_delegates(:did_receive_all_roster_items, pipe)].smash
      end
    
    #### self
    end
     
  #### MessagePipe
  end

#### AgentXmpp
end
