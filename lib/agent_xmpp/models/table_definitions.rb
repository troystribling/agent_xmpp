##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class << self

    #####-----------------------------------------------------------------------------------------------------
    def create_in_memory_db
      in_memory_db.create_table :roster do
      	primary_key :id
      	foreign_key :contact_id, :contacts
        column :status, :text
        column :jid, :text
      end
      in_memory_db.create_table :services do
      	primary_key :id
      end
      in_memory_db.create_table :service_items do
      	primary_key :id
      end
      in_memory_db.create_table :service_features do
      	primary_key :id
      end
      in_memory_db.create_table :publications do
      	primary_key :id
      end
      in_memory_db.create_table :subscriptions do
      	primary_key :id
      end
    end

    #####-----------------------------------------------------------------------------------------------------
    def create_agent_xmpp_db
      unless agent_xmpp_db.table_exists? :version
        agent_xmpp_db.create_table :version do
          integer :number
        end
      end
      version << {:number=>1} if version.count.eql?(0)
      unless agent_xmpp_db.table_exists? :contacts
        agent_xmpp_db.create_table :contacts do
        	primary_key :id
        	column :groups, :text
        	column :jid, :text, :unique=>true
        end
      end
      unless agent_xmpp_db.table_exists? :messages
        agent_xmpp_db.create_table :messages do
        	primary_key :id
        	foreign_key :contact_id, :contacts
        	column :message_text, :text
        	column :text_type, :text
        	column :to_jid, :text
        	column :from_jid, :text
        	column :node, :text
        	column :item_id, :text
          DateTime :created_at;
        end
      end
    end

    #####-----------------------------------------------------------------------------------------------------
    def upgrade_agent_xmpp_db
    end

  #### self
  end
    
#### AgentXmpp 
end
