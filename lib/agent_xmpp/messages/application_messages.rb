##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  module ApplicationMessages
    
    ####......................................................................................................
    # result mesages
    #.........................................................................................................
    def result_jabber_x_data(payload, params)
      iq = Xmpp::Iq.new(:result, params[:from])
      iq.id = params[:id] unless params[:id].nil?
      iq.command = Xmpp::Command::IqCommand.new(params[:node], 'completed')
      iq.command << payload
      Send(iq)      
    end

    #.........................................................................................................
    def result_message_chat(payload, params)
      message = Xmpp::Message.new(params[:from], payload)
      message.type = :chat
      Send(message)  
    end
 
    ####......................................................................................................
    # error messages
    #.........................................................................................................
    def error_unsupported_payload(params)
      error(params, 'bad-request', 'unsupported payload')
    end


    #.........................................................................................................
    def error_no_route(params)
      error(params, 'item-not-found', 'no route for specified command node')
    end

  ####........................................................................................................
  private
    
  #.........................................................................................................
  def error(params, condition, text)
    iq = Xmpp::Iq.new(:error, params[:from])
    iq.id = params[:id] unless params[:id].nil?
    iq.command = Xmpp::Command::IqCommand.new(params[:node], params[:action])
    iq.command << Xmpp::ErrorResponse.new(condition, text)
    Send(iq)
  end
          
  #### RequestMessages
  end
  
#### AgentXmpp
end
