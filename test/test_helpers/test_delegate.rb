##############################################################################################################
class TestDelegate

  ####------------------------------------------------------------------------------------------------------
  class << self
    
    #.........................................................................................................
    def delegate_callbacks(*args)
      args.each do |meth| 
        instance_eval <<-do_eval
          def #{meth.to_s}(*args)
            AgentXmpp.logger.info "TEST_DELEGATE #{meth.to_s.upcase}"
            @#{meth.to_s}_flag = true
            []
          end
          def #{meth.to_s}_flag
            @#{meth.to_s}_flag
          end
          @#{meth.to_s}_flag = false
        do_eval
      end
    end 
                         
  end
  
  #---------------------------------------------------------------------------------------------------------
  #### connection
  delegate_callbacks :did_connect, :did_disconnect, :did_not_connect

  #### authentication
  delegate_callbacks :did_authenticate, :did_not_authenticate, :did_bind, :did_start_session

  #### presence
  delegate_callbacks :did_receive_presence, :did_receive_subscribe_request, :did_receive_unsubscribed_request

  #### roster management
  delegate_callbacks :did_receive_roster_item, :did_remove_roster_item, :did_receive_all_roster_items, :did_acknowledge_add_contact, 
                     :did_remove_contact, :did_add_contact 

  #### service discovery management
  delegate_callbacks :did_receive_client_version_result,:did_receive_client_version_request
  
#### TestDelegate 
end
