##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class RosterModel

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      def roster
        @roster ||= AgentXmpp.in_memory_db[:roster]
      end

      #.........................................................................................................
      def update(presence)
        from_jid = presence.from.to_s    
        contact = ContactModel.find_by_jid(presence.from)
        status = presence.type.nil? ? 'available' : presence.type.to_s 
        if (contact)
          begin
            roster << {:jid => from_jid, :status => status, :contact_id => contact[:id]}
          rescue 
            roster.filter(:jid => from_jid).update(:status => status)
          end
        end
      end
 
      #.........................................................................................................
      def update_status(jid, status)
        roster.filter(:jid => jid.to_s).update(:status => status.to_s)
      end
        
      #.........................................................................................................
      def update_client_version(version)
        from_jid = version.from.to_s
        vquery = version.query
        if (item = roster.filter(:jid => from_jid))  
          item.update(:client_name => vquery.iname, :client_version => vquery.version, :client_os => vquery.os)
        end
      end
        
      #.........................................................................................................
      def find_all
        roster.all  
      end

      #.........................................................................................................
      def find_by_jid(jid)
        roster[:jid => jid.to_s]
      end 
      
      #.........................................................................................................
      def find_all_by_status(status)
        roster.filter(:status => status.to_s).all
      end

      #.........................................................................................................
      def find_all_by_contact_jid(jid)
        if contact = ContactModel.find_by_jid(jid)
          roster.filter(:contact_id => contact[:contact_id]).all
        else; []; end
      end 
      
      #.........................................................................................................
      def find_all_by_contact_jid_and_status(jid, status)
        if contact = ContactModel.find_by_jid(jid)
          roster.filter(:jid => jid.to_s, :contact_id => contact[:contact_id]).all
        else; []; end
      end 
      
      #.........................................................................................................
      def destroy_by_contact_id(jid)
        roster.filter(:contact_id => contact_id).delete
      end 

      #.........................................................................................................
      def method_missing(meth, *args, &blk)
        roster.send(meth, *args, &blk)
      end

    #### self
    end

    #.........................................................................................................
    #.........................................................................................................
    def initialize(jid, roster)
      @items = {}
      roster.each{|r| @items[r['jid']] = {:status => :inactive, :resources => {}, :groups => r['groups'].nil? ? [] : r['groups'].uniq, :jid => r['jid']}} if roster
      @items[jid.bare.to_s] = {:status => :both, :resources => {}, :groups => [],}
      @items[jid.domain] = {:status => :host, :resources => {jid.domain => {}}, :groups => []}
    end

    #.........................................................................................................
    def update(presence)
      RosterModel.update(presence)   
      from_jid, from_bare_jid = presence.from.to_s, presence.from.bare.to_s 
      ## remove here
      if @items[from_bare_jid]
        @items[from_bare_jid][:resources][from_jid] ||= {}
        @items[from_bare_jid][:resources][from_jid][:presence] = presence
      end
      ## <-----
    end

    #.........................................................................................................
    def update_client_version(version)
      RosterModel.update_client_version(version)   
      from_jid, from_bare_jid = version.from.to_s, version.from.bare.to_s
      ## remove here ---->
      if @items[from_bare_jid] and @items[from_bare_jid][:resources][from_jid]   
        @items[from_bare_jid][:resources][from_jid][:version] = version.query
      end        
      ## <-----
    end

    #.........................................................................................................
    #.........................................................................................................
                    
    #.........................................................................................................
    def has_version?(jid)
      if @items[jid.bare.to_s] and @items[jid.bare.to_s][:resources][jid.to_s]
        not @items[jid.bare.to_s][:resources][jid.to_s][:version].nil?
      else 
        false
      end
    end 
                    
    #.........................................................................................................
    def update_roster_item(roster_item)
      if @items[roster_item.jid.to_s]
        @items[roster_item.jid.to_s][:roster_item] = roster_item 
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
