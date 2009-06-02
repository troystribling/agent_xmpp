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
      container_type = case format.xmlns
        when 'jabber:x:data' then :add_x_data_to_container
        when 'message:chat'  then :add_chat_message_body_container
      end
      container_type.nil? ? nil : send(container_type, payload)
    end

  private
 
    #.........................................................................................................
    def add_x_data_to_container(payload)
      iq = Jabber::Iq.new(:result, params[:from])
      iq.id = params[:id] unless params[:id].nil?
      iq.command = Jabber::Command::IqCommand.new(params[:node], 'completed')
      iq.command << payload
      iq      
    end

    #.........................................................................................................
    def add_chat_message_body_container(payload)
      message = Jabber::Message.new(params[:from], payload)
      message.type = :chat
      message      
    end
      
  #### View
  end

#### AgentXmpp
end
