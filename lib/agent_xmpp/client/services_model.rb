##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class ServicesModel

    #.........................................................................................................
    def initialize
      @service = Hash.new{|hash, key| hash[key] = {}}
    end

    #.........................................................................................................
    def find_all_by_item_category(cat)
      @service.select{|(k,v)| not v[:discoinfo].identities.select{|i| i.category.eql?(cat)}.empty?} 
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
      @service[from_jid][:discoinfo] = disco.query 
    end
 
    #.........................................................................................................
    def update_with_discoitems(disco)      
      from_jid = disco.from.to_s     
      @service[from_jid][:discoitems] = disco.query 
    end

    #.........................................................................................................
    def method_missing(meth, *args, &blk)
      @service.send(meth, *args, &blk)
    end

  #### ServicesModel
  end

#### AgentXmpp
end
