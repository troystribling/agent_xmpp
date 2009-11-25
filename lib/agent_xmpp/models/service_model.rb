##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class ServiceModel

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      def services
        @roster ||= AgentXmpp.in_memory_db[:services]
      end

      #.........................................................................................................
      def service_items
        @service_items ||= AgentXmpp.in_memory_db[:service_items]
      end

      #.........................................................................................................
      def service_features
        @service_features ||= AgentXmpp.in_memory_db[:service_features]
      end

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
    def update_with_discoinfo(disco)
      save_item_disco(:discoinfo, disco)
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
