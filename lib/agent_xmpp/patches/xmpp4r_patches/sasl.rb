##############################################################################################################
module Jabber  
  module SASL
    class Plain
  
      #.....................................................................................................
      def auth(password, &blk)
        auth_text = "#{@stream.jid.strip}\x00#{@stream.jid.node}\x00#{password}"
        @stream.send(generate_auth('PLAIN', Base64::encode64(auth_text).gsub(/\s/, '')), &blk)
      end
    
    ##### Plain
    end
  ##### SASL
  end
#### AgentXmpp
end
