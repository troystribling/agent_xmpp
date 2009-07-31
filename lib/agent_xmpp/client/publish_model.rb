##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class PublishModel

    #.........................................................................................................
    def initialize(items)
      @items = items.nil? ? [] : items.map{|i| i.update('status' => :unknown)}
    end

    #.........................................................................................................
    def find_all
      @items.collect{|i| PublishNode.new(i)}
    end

    #.........................................................................................................
    def find_by_node(node)
      item = @items.select{|i| node.split('/').last.eql?(i['node'])}.first
      item.nil? ? nil : PublishNode.new(item)
    end

    #.........................................................................................................
    def find_all_by_status(status)
      @items.select{|i| i['status'].eql?(status.to_sym)}
    end

    #.........................................................................................................
    def delete_by_node(node)
      @items.delete_if{|i| node.split('/').last.eql?(i['node'])}
    end

    #.........................................................................................................
    def update_status(node, status)
      i = @items.select{|i| node.split('/').last.eql?(i['node'])}.first
      if i
        delete_by_node(node)
        i['status'] = status
        @items << i; true
      else; false; end
    end

    #.........................................................................................................
    def all_are_active?
      find_all_by_status(:active).count.eql?(@items.count)
    end

  #### PublishModel
  end

  #####-------------------------------------------------------------------------------------------------------
  class PublishNode

    #.........................................................................................................
    attr_reader :node, :status, :title, :access_model, :publish_model, :send_last_published_item, :max_items,
                :max_payload_size, :deliver_notifications, :deliver_payloads, :persist_items, 
                :subscribe, :presence_based_delivery, :notify_config, :notify_delete, :notify_retract,
                :notify_sub
      
    #.........................................................................................................
    def initialize(pub)
      @node = pub['node']
      @status = pub['status']
      @title = pub['title']
      @access_model = pub['access_model']
      @publish_model = pub['publish_model']
      @send_last_published_item = pub['send_last_published_item']
      @max_items = pub['max_items']
      @max_payload_size = pub['max_payload_size']
      @deliver_notifications = pub['deliver_notifications']
      @deliver_payloads = pub['deliver_payloads']
      @persist_items = pub['persist_items']
      @subscribe = pub['subscribe']
      @presence_based_delivery = pub['presence_based_delivery']
      @notify_config = pub['notify_config']
      @notify_delete = pub['notify_delete']
      @notify_retract = pub['notify_retract']
      @notify_sub = pub['notify_sub']
    end

  #### PublishNode
  end

#### AgentXmpp
end
