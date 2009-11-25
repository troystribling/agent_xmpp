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
      end
      in_memory_db.create_table :service_items do
      	primary_key :id
        column :parentNode, :text
        column :service, :text
        column :node, :text
        column :jid, :text
        column :itemName, :text
      end
      in_memory_db.create_table :service_features do
      	primary_key :id
        column :parentNode, :text
        column :service, :text
        column :var, :text
      end
      in_memory_db.create_table :publications do
      	primary_key :id
        column :node, :text
        column :status, :text
        column :title, :text
        column :access_model, :text
        column :publish_model, :text
        column :send_last_published_item, :integer
        column :max_items, :integer
        column :max_payload_size, :integer
        column :deliver_notifications, :integer
        column :deliver_payloads, :integer
        column :persist_items, :integer
        column :subscribe, :integer
        column :presence_based_delivery
        column :notify_config, :integer
        column :notify_delete, :integer
        column :notify_retract, :integer
        column :notify_sub, :integer
      end
      in_memory_db.create_table :subscriptions do
      	primary_key :id
      	column :subId, :text
        column :node, :text
        column :service, :text
        column :subscription, :text
        column :jid, :text
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
        	column :role, :text
          column :ask, :text
          column :subscription, :text
          column :status, :text
        	column :groups, :text
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
