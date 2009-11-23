##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class RosterModel

    #.........................................................................................................
    def initialize(jid, roster)
      @items = {}
      roster.each{|r| @items[r['jid']] = {:status => :inactive, :resources => {},
        :groups => r['groups'].nil? ? [] : r['groups'].uniq, :jid => r['jid']}} if roster
      @items[jid.bare.to_s] = {:status => :both, :resources => {}, :groups => [],}
      @items[jid.domain] = {:status => :host, :resources => {jid.domain => {}}, :groups => []}
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
      @items[jid.bare.to_s].nil? ? nil : RosterItemModel.new(@items[jid.bare.to_s])   
    end

    #.........................................................................................................
    def find_all_by_status(status)
      @items.select{|j,r| r[:status].eql?(status)}.map{|j,r| RosterItemModel.new(r)}    
    end

    #.........................................................................................................
    def find_all_by_group(group)
      @items.select{|j,r| r[:group].include?(group)}.map{|j,r| RosterItemModel.new(r)}    
    end

    #.........................................................................................................
    def destroy_by_jid(jid)
      @items.delete(jid.bare.to_s)
    end 
    
    #.........................................................................................................
    def has_resource?(jid)
      not @items[jid.bare.to_s][:resources][jid.to_s].nil?
    end 

    #.........................................................................................................
    def resources(jid)
      @items[jid.bare.to_s][:resources]
    end 
    
    #.........................................................................................................
    def available_resources(jid)
      if @items[jid.bare.to_s] and @items[jid.bare.to_s][:resources]
        @items[jid.bare.to_s][:resources].inject([]) {|r,(j,h)| h[:presence].status.nil? ? r << j : r}
      else; []; end
    end 
    
    #.........................................................................................................
    def resource(jid)
      if @items[jid.bare.to_s] and @items[jid.bare.to_s][:resources][jid.to_s]
        @items[jid.bare.to_s][:resources][jid.to_s][:presence]
      end
    end 

    #.........................................................................................................
    def version(jid)
      if @items[jid.bare.to_s] and @items[jid.bare.to_s][:resources][jid.to_s]
        @items[jid.bare.to_s][:resources][jid.to_s][:version]
      end
    end 
                    
    #.........................................................................................................
    def has_version?(jid)
      if @items[jid.bare.to_s] and @items[jid.bare.to_s][:resources][jid.to_s]
        not @items[jid.bare.to_s][:resources][jid.to_s][:version].nil?
      else 
        false
      end
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
      @items[from_bare_jid][:resources][from_jid] ||= {}
      @items[from_bare_jid][:resources][from_jid][:presence] = presence
    end
 
    #.........................................................................................................
    def update_resource_version(version)
      from_jid = version.from.to_s     
      from_bare_jid = version.from.bare.to_s     
      if @items[from_bare_jid][:resources][from_jid]   
        @items[from_bare_jid][:resources][from_jid][:version] = version.query
      end        
    end
        
    #.........................................................................................................
    def method_missing(meth, *args, &blk)
      @items.send(meth, *args, &blk)
    end

  #### RosterModel
  end

  #####-------------------------------------------------------------------------------------------------------
  class RosterItemModel

    #.........................................................................................................
    attr_reader :status, :groups, :jid, :priority
    
    #.........................................................................................................
    def initialize(item)
      @status = item[:status]
      @groups = item[:groups]
      @jid = item[:jid]
      @priority = item[:priority]
    end

  #### RosterItemModel
  end

#### AgentXmpp
end
