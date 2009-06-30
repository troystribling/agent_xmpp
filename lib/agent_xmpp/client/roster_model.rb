##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class RosterModel

    #.........................................................................................................
    def initialize(jid, roster)
      @items = Hash.new{|hash, key| hash[key] = {:status => :inactive, :resources => {}}}
      roster.each{|r| @items[r]}
      @items[jid.bare.to_s] = {:status => :both, :resources => {}}
    end

    #.........................................................................................................
    def has_jid?(jid)
      @items.has_key?(jid.bare.to_s) 
    end

    #.........................................................................................................
    def find_all
      @items.values.collect{|r| RosterItemModel.new(r)}  
    end

    #.........................................................................................................
    def find_by_jid(jid)
      @items[jid.bare.to_s].nil? ? nil : RosterItemModel.new(@items[jid])   
    end

    #.........................................................................................................
    def find_all_by_status(status)
      @items.select{|j,r| r[:status].eql?(status)}    
    end

    #.........................................................................................................
    def destroy_by_jid(jid)
      @items.delete(jid.bare.to_s)
    end 
    
    #.........................................................................................................
    def features(jid)
      if @items[jid.bare.to_s] and @items[jid.bare.to_s][:resources][jid.to_s]
        @items[jid.bare.to_s][:resources][jid.to_s][:discoinfo].features
      else 
        []
      end
    end 

    #.........................................................................................................
    def has_feature?(jid, feature)
       features.include?(feature)
    end 

    #.........................................................................................................
    def identities(jid)
      if @items[jid.bare.to_s] and @items[jid.bare.to_s][:resources][jid.to_s]
        @items[jid.bare.to_s][:resources][jid.to_s][:discoinfo].identities
      else 
        []
      end
    end 

    #.........................................................................................................
    def has_identity?(jid, item)
      @items.delete(jid)
    end 
    
    #.........................................................................................................
    def update_status(jid, status)
      @items[jid.bare.to_s][:status] = status
    end

    #.........................................................................................................
    def update_roster_item(roster_item)
      @items[roster_item.jid.to_s][:roster_item] = roster_item 
    end

    #.........................................................................................................
    def update_resource(presence)
      from_jid = presence.from.to_s     
      from_bare_jid = presence.from.bare.to_s     
      @items[from_bare_jid.to_s][:resources][from_jid] ||= {}
      @items[from_bare_jid.to_s][:resources][from_jid][:presence] = presence
    end
 
    #.........................................................................................................
    def update_resource_version(from, version)
      @items[from.bare.to_s][:resources][from.to_s][:version] = version \
        if @items[from.bare.to_s][:resources][from.to_s]
    end
    
    #.........................................................................................................
    def update_resource_discoinfo(from, disco)
      @items[from.bare.to_s][:resources][from.to_s][:discoinfo] = disco \
        if @items[from.bare.to_s][:resources][from.to_s]
    end
    
    #.........................................................................................................
    def method_missing(meth, *args, &blk)
      @items.send(meth, *args, &blk)
    end

  #### Roster
  end

  #####-------------------------------------------------------------------------------------------------------
  class RosterItemModel

    #.........................................................................................................
    attr_reader :status
    
    #.........................................................................................................
    def initialize(item)
      @status = item[:status]
    end

  #### Roster
  end

#### AgentXmpp
end
