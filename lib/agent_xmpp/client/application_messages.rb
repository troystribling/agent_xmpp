##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  module ApplicationMessages
    
    #.........................................................................................................
    def response_jabber_x_data(payload, params)
      iq = Jabber::Iq.new(:result, params[:from])
      iq.id = params[:id] unless params[:id].nil?
      iq.command = Jabber::Command::IqCommand.new(params[:node], 'completed')
      iq.command << payload
      iq      
    end

    #.........................................................................................................
    def response_message_chat(payload, params)
      message = Jabber::Message.new(params[:from], payload)
      message.type = :chat
      message      
    end
 
    #.........................................................................................................
    def error_unsupported_payload(params)
      iq = Jabber::Iq.new(:error, params[:from])
      iq
    end

    #.........................................................................................................
    def error_x_payload_not_specified(params)
      iq = Jabber::Iq.new(:error, params[:from])
      iq
    end
    
  #### RequestMessages
  end
  
#### AgentXmpp
end
