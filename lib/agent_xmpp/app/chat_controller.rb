############################################################################################################
class ChatController < AgentXmpp::Controller

  #.........................................................................................................
  def body
    AgentXmpp.logger.info "ACTION: ChatController\#body"
    result_for do
      params[:body].reverse
    end
    respond_to do |result|
      result.to_s
    end
  end
  
#### ChatMessageBodyController
end
