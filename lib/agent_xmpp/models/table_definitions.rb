##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class << self

    #####-----------------------------------------------------------------------------------------------------
    def create_in_memory_db
      in_memory_db.create_table :roster do
      	primary_key :id
      	column :contact_id, :integer
        column :jid, :text, :unique=>true
      	column :status, :text
        column :client_name, :text
        column :client_version, :text
        column :client_os, :text
      end
      in_memory_db.create_table :services do
      	primary_key :id
        column :jid, :text
        column :name, :text
        column :category, :text
        column :type, :text
        column :node, :text
        unique [:node, :jid]
      end
      in_memory_db.create_table :service_items do
      	primary_key :id
        column :parent_node, :text
        column :service, :text
        column :node, :text
        column :jid, :text
        column :name, :text
        unique [:node, :service]
      end
      in_memory_db.create_table :service_features do
      	primary_key :id
        column :node, :text
        column :service, :text
        column :var, :text
        unique [:node, :service, :var]
      end
      in_memory_db.create_table :publications do
      	primary_key :id
        column :node, :text, :unique=>true
        column :status, :text
        column :title, :text
        column :access_model, :text
        column :max_items, :integer
        column :deliver_notifications, :integer
        column :deliver_payloads, :integer
        column :persist_items, :integer
        column :subscribe, :integer
        column :notify_config, :integer
        column :notify_delete, :integer
        column :notify_retract, :integer
      end
      in_memory_db.create_table :subscriptions do
      	primary_key :id
        column :node, :text, :unique=>true
        column :service, :text
        column :subscription, :text
      end
    end

    #####-----------------------------------------------------------------------------------------------------
    def create_agent_xmpp_db
      unless agent_xmpp_db.table_exists? :version
        agent_xmpp_db.create_table :version do
        	primary_key :id
          integer :number
        end
      end
      version << {:number=>1} if version.count.eql?(0)
      unless agent_xmpp_db.table_exists? :contacts
        agent_xmpp_db.create_table :contacts do
        	primary_key :id
        	column :jid, :text, :unique=>true
          column :ask, :text
          column :subscription, :text
        	column :groups, :text
        end
      end
      unless agent_xmpp_db.table_exists? :messages
        agent_xmpp_db.create_table :messages do
        	primary_key :id
        	column :message_text, :text
        	column :content_type, :text
        	column :message_type, :text
        	column :to_jid, :text
        	column :from_jid, :text
        	column :node, :text
        	column :item_id, :text
          Time :created_at
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
