##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class ServicesModel

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
    def identities(jid)
      has_jid?(jid.to_s) ? @service[from_jid][:discoinfo].identities : []
    end 

    #.........................................................................................................
    def features(jid)
      has_jid?(jid.to_s) ? @service[from_jid][:discoinfo].features : []
    end 
        
    #.........................................................................................................
    def items(jid)
      has_jid?(jid.to_s) ? @service[from_jid][:discoitems].items : []
    end 
        
    #.........................................................................................................
    def update_with_discoinfo(disco)
      from_jid = disco.from.to_s  
      node = disco.query.node
      if node 
        @service[from_jid][:discoinfo] = disco.query 
      else
        @service[from_jid][:node] = {} if @service[from_jid][:node].nil?
        @service[from_jid][:node][node] = {} if @service[from_jid][:node][node].nil?
        @service[from_jid][:node][node][:discoinfo] = disco.query 
      end
    end
 
    #.........................................................................................................
    def update_with_discoitems(disco)      
      from_jid = disco.from.to_s     
      node = disco.query.node
      if node 
        @service[from_jid][:discoitems] = disco.query 
      else
        @service[from_jid][:node] = {} if @service[from_jid][:node].nil?
        @service[from_jid][:node][node] = {} if @service[from_jid][:node][node].nil?
        @service[from_jid][:node][node][:discoitems] = disco.query 
      end
    end

    #.........................................................................................................
    def method_missing(meth, *args, &blk)
      @service.send(meth, *args, &blk)
    end

  #### ServicesModel
  end

#### AgentXmpp
end
