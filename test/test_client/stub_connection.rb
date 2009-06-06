##############################################################################################################
class AgentXmpp::Connection 
  
  #.........................................................................................................
  def send(data, &blk)
    raise NotConnected if error?
    if block_given? and data.is_a? Jabber::XMPPStanza
      if data.id.nil?
        data.id = Jabber::IdGenerator.instance.generate_id
      end
      @id_callbacks[data.id] = blk
    end
    puts data.to_s
    AgentXmpp.logger.info "SEND: #{data.to_s}"
  end
  
  
#### AgentXmpp::Connection  
end