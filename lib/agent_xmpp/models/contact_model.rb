##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class ContactModel

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      def contacts
        @contacts ||= AgentXmpp.agent_xmpp_db[:contacts]
      end

      #.........................................................................................................
      def load_config
        if AgentXmpp.config['roster'].kind_of?(Array)
          AgentXmpp.config['roster'].each do |c|
            groups = c["groups"].kind_of?(Array) ? c["groups"].join(",") : []
            begin
              contacts << {:jid => c["jid"], :groups => groups}
            rescue 
              contacts.filter(:jid => c["jid"]).update(:groups => groups)
            end
          end
        end
      end

      #.........................................................................................................
      def method_missing(meth, *args, &blk)
        contacts.send(meth, *args, &blk)
      end

    #### self
    end

  #### ContactModel
  end

#### AgentXmpp
end
