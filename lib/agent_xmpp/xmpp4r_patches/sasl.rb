##############################################################################################################
module Jabber
  module SASL
    class Base

      def initialize
      end

    end
  end
end

##############################################################################################################
module Jabber  
  module SASL
    
    ####----------------------------------------------------------------------------------------------------
    def SASL.new(mechanism)
      case mechanism
        when 'DIGEST-MD5'
          DigestMD5.new
        when 'PLAIN'
          Plain.new
        when 'ANONYMOUS'
          Anonymous.new
        else
          raise AgentXmppError "Unknown SASL mechanism: #{mechanism}"
      end
    end
    
    ####----------------------------------------------------------------------------------------------------
    class Plain
  
      #.....................................................................................................
      def auth(jid, password)
        auth_text = "#{jid.strip}\x00#{jid.node}\x00#{password}"
        generate_auth('PLAIN', Base64::encode64(auth_text).gsub(/\s/, ''))
      end
    
    ##### Plain
    end
  ##### SASL
  end
#### AgentXmpp
end
