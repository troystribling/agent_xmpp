##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  module Parser

    #---------------------------------------------------------------------------------------------------------
    include EventMachine::XmlPushParser
    #---------------------------------------------------------------------------------------------------------

    #---------------------------------------------------------------------------------------------------------
    attr_reader :stream_features, :stream_mechanisms
    #---------------------------------------------------------------------------------------------------------

    #---------------------------------------------------------------------------------------------------------
    # EventMachine::XmlPushParser callbacks
    #.........................................................................................................
  	def start_document
  	end
  
    #.........................................................................................................
    def start_element(name, attrs)
      e = REXML::Element.new(name)
      e.add_attributes(attrs)      
      @current = @current.nil? ? e : @current.add_element(e)  
      if @current.xpath == 'stream:stream'
        process
        @current = nil
      end
    end
  
    #.........................................................................................................
    def end_element(name)
      if @current.parent
        @current = @current.parent
      else
        process
        @current = nil
      end
    end

    #.........................................................................................................
    def characters(text)
      @current.text = @current.text.to_s + text if @current
    end

    #.........................................................................................................
    def error(*args)
      AgentXmpp.logger.error *args
    end

    #.........................................................................................................
    def process
      @current.add_namespace(@streamns) if @current.namespace('').to_s.eql?('')
      begin
        stanza = Jabber::XMPPStanza::import(@current)
      rescue Jabber::NoNameXmlnsRegistered
        stanza = @current
      end
      if @current.xpath.eql?('stream:stream')
        @streamns = @current.namespace('') if @current.namespace('')
      end
      receive(stanza) if respond_to?(:receive)
    end
   
  #### Parser
  end

#### AgentXmpp
end

