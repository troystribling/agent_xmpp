##############################################################################################################
class TestDelegate

  ####------------------------------------------------------------------------------------------------------
  class << self
    
    #.........................................................................................................
    @@callback_methods = []
    
    #.........................................................................................................
    def delegate_callbacks(*args)
      args.each do |meth| 
        @@callback_methods.push(meth)
        class_eval <<-do_eval
          def #{meth}(*args)
            AgentXmpp.logger.info "TEST_DELEGATE #{meth.to_s.upcase}"
            @#{meth}_method = true
            nil
          end
          def #{meth}_method
            [@#{meth}_method, "#{meth.to_s}"]
          end
          attr_writer :#{meth}_method
        do_eval
      end
    end 
                         
  end
  
  #---------------------------------------------------------------------------------------------------------
  #### connection
  delegate_callbacks :on_connect, :on_disconnect, :on_did_not_connect, :on_did_not_authenticate

  #### authentication
  delegate_callbacks :on_authenticate, :on_bind, :on_start_session, :on_preauthenticate_features,
                     :on_postauthenticate_features

  #### presence
  delegate_callbacks :on_presence, :on_presence_subscribe, :on_presence_unsubscribed, :on_presence_subscribed, :on_presence_unavailable

  #### roster management
  delegate_callbacks :on_roster_item, :on_all_roster_items, :on_acknowledge_add_roster_item, 
                     :on_roster_result, :on_roster_set, :on_remove_roster_item, :on_acknowledge_remove_roster_item, 
                     :on_remove_roster_item_error, :on_add_roster_item_error

  #### service discovery management
  delegate_callbacks :on_version_result, :on_version_get, :on_version_error, :on_discoinfo_result,
                     :on_discoinfo_get, :on_discoitems_get, :on_discoitems_result,
                     :on_discoinfo_error, :on_discoitems_error

   #### errors
   delegate_callbacks :on_unsupported_message
  
  #---------------------------------------------------------------------------------------------------------
  def initialize
    @@callback_methods.each{|m| send("#{m.to_s}_method=".to_sym, false)}
  end
  
#### TestDelegate 
end
