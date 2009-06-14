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
          def #{meth.to_s}(*args)
            AgentXmpp.logger.info "TEST_DELEGATE #{meth.to_s.upcase}"
            @#{meth.to_s}_method = true
            []
          end
          def #{meth.to_s}_method
            [@#{meth.to_s}_method, "#{meth.to_s}"]
          end
          attr_writer :#{meth.to_s}_method
        do_eval
      end
    end 
                         
  end
  
  #---------------------------------------------------------------------------------------------------------
  #### connection
  delegate_callbacks :did_disconnect

  #### authentication
  delegate_callbacks :did_authenticate, :did_bind, :did_start_session

  #### presence
  delegate_callbacks :did_receive_presence, :did_receive_subscribe_request, :did_receive_unsubscribed_request

  #### roster management
  delegate_callbacks :did_receive_roster_item, :did_receive_all_roster_items, :did_acknowledge_add_roster_item, 
                     :did_remove_roster_item, :did_acknowledge_remove_roster_item

  #### service discovery management
  delegate_callbacks :did_receive_client_version_result,:did_receive_client_version_request
  
  #---------------------------------------------------------------------------------------------------------
  def initialize
    @@callback_methods.each{|m| send("#{m.to_s}_method=".to_sym, false)}
  end
  
#### TestDelegate 
end
