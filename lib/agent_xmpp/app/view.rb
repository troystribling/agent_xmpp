##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class View

    #---------------------------------------------------------------------------------------------------------
    attr_reader :connection, :format, :params
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize(connection, format, params)
      @connection = connection
      @format = format
      @params = params
    end
           
    #.........................................................................................................
    def add_payload_to_container(payload)
      meth = "response_#{format.xmlns.gsub(/:/, "_")}".to_sym
      if connection.respond_to?(meth) 
        connection.send_to_method(meth, payload, params) 
      else
        AgentXmpp.logger.error /
          "PAYLOAD ERROR: unsupported payload {:xmlns => '#{params[:xmlns]}', :node => '#{params[:node]}', :action => '#{params[:action]}'}."
        connection.error_unsupported_payload(params)
      end
    end

  private
       
  #### View
  end

#### AgentXmpp
end
