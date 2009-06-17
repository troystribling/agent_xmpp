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
      connection.respond_to?(meth) ? connection.send(meth, payload, params) : connection.error_unsupported_payload(params)
    end

  private
       
  #### View
  end

#### AgentXmpp
end
