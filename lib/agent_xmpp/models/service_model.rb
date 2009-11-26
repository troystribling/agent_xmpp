##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class ServiceModel

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      def services
        @services ||= AgentXmpp.in_memory_db[:services]
      end

      #.........................................................................................................
      def service_items
        @service_items ||= AgentXmpp.in_memory_db[:service_items]
      end

      #.........................................................................................................
      def service_features
        @service_features ||= AgentXmpp.in_memory_db[:service_features]
      end

      #.........................................................................................................
      def update(disco_iq)
        disco = disco_iq.query
p disco.class
        case disco
          when AgentXmpp::Xmpp::IqDiscoInfo then update_with_disco_info(disco_iq)
          # when AgentXmpp::Xmpp::IqDiscoItems then update_with_disco_items(disco_iq)
        end
      end

      #.........................................................................................................
      # private
      #.........................................................................................................
      def update_with_disco_info(disco_iq)
        disco, service = disco_iq.query, disco_iq.from.to_s
        parent = disco.node
        disco.identities.each do |i|
          services << {:node => parent, :jid => service, :category => i.category, :type => i.type, :name => i.iname}
        end
        disco.features.each do |f|
          service_features << {:parent_node => parent, :service => service, :var => f.var}
        end
      end

      #.........................................................................................................
      def update_with_disco_items(disco_iq)
p disco_iq
        disco, service = disco_iq.query, disco_iq.from.to_s
        parent = disco.node
        disco.items.each do |i|
          services << {:node => parent, :jid => service, :category => i.category, :type => i.type, :name => i.iname}
        end
      end

      #.........................................................................................................
      private :update_with_disco_info, :update_with_disco_items

    #### self
    end

    #.........................................................................................................
    def initialize
      @service = Hash.new{|hash, key| hash[key] = {}}
    end

    #.........................................................................................................
    def find_all_by_category(cat)
      @service.select{|(k,v)| not v[:discoinfo].identities.select{|i| i.category.eql?(cat)}.empty?} 
    end

    #.........................................................................................................
    def find_all_by_category_and_type(cat)
      @service.select{|(k,v)| not v[:discoinfo].identities.select{|i| i.category.eql?(cat) and i.type.eql?(type)}.empty?} 
    end

    #.........................................................................................................
    def create(jid)
      @service[jid.to_s] = {} 
    end

    #.........................................................................................................
    def has_jid?(jid)
      @service.has_key?(jid.to_s) 
    end

    #.........................................................................................................
    def has_feature?(jid, feature)
       not features(jid.to_s).select{|f| f.var.eql?(feature)}.empty?
    end 

    #.........................................................................................................
    def has_item?(jid, ijid)
      not items(jid.to_s).select{|i| i.jid.eql?(i.jid)}.empty?
    end 

    #.........................................................................................................
    def identities(jid, node=nil)
      if has_jid?(jid.to_s) 
        node.nil ? @service[from_jid][:discoinfo].identities : @service[from_jid][:node][node][:discoinfo].identities
      else; []; end
    end 

    #.........................................................................................................
    def features(jid, node=nil)
      if has_jid?(jid.to_s) 
        node.nil ? @service[from_jid][:discoinfo].features : @service[from_jid][:node][node][:discoinfo].features 
      else; []; end
    end 
        
    #.........................................................................................................
    def items(jid, node=nil)
      if has_jid?(jid.to_s) 
        node.nil ? @service[from_jid][:discoitems].items : @service[from_jid][:node][node][:discoitems].items 
      else; []; end
    end 
        
    #.........................................................................................................
    def update_with_discoitems(disco)      
      save_item_disco(:discoitems, disco)
    end

    #.........................................................................................................
    def method_missing(meth, *args, &blk)
      @service.send(meth, *args, &blk)
    end

  private
  
    #.........................................................................................................
    def save_item_disco(item, disco)
      from_jid = disco.from.to_s  
      node = disco.query.node
      unless node 
        @service[from_jid][:node] = {} if @service[from_jid][:node].nil?
        @service[from_jid][:node][node] = {} if @service[from_jid][:node][node].nil?
        @service[from_jid][:node][node][item] = disco.query 
      else
        @service[from_jid][item] = disco.query 
      end
    end
  
  #### ServiceModel
  end

#### AgentXmpp
end
