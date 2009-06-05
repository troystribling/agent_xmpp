############################################################################################################
class ChatController < AgentXmpp::Controller

  #.........................................................................................................
  def body
    result_for do
      params[:body].reverse
    end
    respond_to do |result|
      result.to_s
    end
    AgentXmpp.logger.info "ACTION: ChatController\#body"
  end
  
#### ChatMessageBodyController
end
