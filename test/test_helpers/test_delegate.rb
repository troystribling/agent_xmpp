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
  delegate_callbacks :did_disconnect

  #### authentication
  delegate_callbacks :did_authenticate, :did_bind, :did_start_session

  #### presence
  delegate_callbacks :did_receive_presence, :did_receive_presence_subscribe, :did_receive_presence_unsubscribed,
                     :did_receive_presence_subscribed

  #### roster management
  delegate_callbacks :did_receive_roster_item, :did_receive_all_roster_items, :did_acknowledge_add_roster_item, 
                     :did_remove_roster_item, :did_acknowledge_remove_roster_item, :did_receive_remove_roster_item_error,
                     :did_receive_add_roster_item_error

  #### service discovery management
  delegate_callbacks :did_receive_version_result,:did_receive_version_get
  
  #---------------------------------------------------------------------------------------------------------
  def initialize
    @@callback_methods.each{|m| send("#{m.to_s}_method=".to_sym, false)}
  end
  
#### TestDelegate 
end
