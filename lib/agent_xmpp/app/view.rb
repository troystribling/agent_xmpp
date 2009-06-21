##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class View

    #---------------------------------------------------------------------------------------------------------
    attr_reader :pipe, :format, :params
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize(pipe, format, params)
      @pipe = pipe
      @format = format
      @params = params
    end
           
    #.........................................................................................................
    def add_payload_to_container(payload)
      meth = "result_#{format.xmlns.gsub(/:/, "_")}".to_sym
      if pipe.respond_to?(meth) 
        pipe.send_to_method(meth, payload, params) 
      else
        AgentXmpp.logger.error /
          "PAYLOAD ERROR: unsupported payload {:xmlns => '#{params[:xmlns]}', :node => '#{params[:node]}', :action => '#{params[:action]}'}."
        pipe.error_unsupported_payload(params)
      end
    end

  private
       
  #### View
  end

#### AgentXmpp
end
