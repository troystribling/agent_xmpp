##############################################################################################################
def Send(msg, &blk)
  AgentXmpp::Response.new(msg, &blk)
end

##############################################################################################################
module AgentXmpp
    
  #####-------------------------------------------------------------------------------------------------------
  class Response

    #.........................................................................................................
    attr_reader :text, :message, :responds_with

    #.........................................................................................................
    def initialize(msg, &blk)
      @message = msg
      @text = msg.to_s
      @responds_with = blk
    end

    #.........................................................................................................
    def to_s
      text
    end
    
    #.........................................................................................................
    def method_missing(meth, *args, &blk)
      text.send(meth, *args, &blk)
    end

  #### Message
  end

#### AgentXmpp
end
