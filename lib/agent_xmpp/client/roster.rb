##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class Roster

    #.........................................................................................................
    def initialize(jid, contacts)
      @items = Hash.new{|hash, key| hash[key] = {:status => :inactive, :resources => {}}}
      contacts.each{|c| @items[c]}
      @items[jid.bare.to_s] = {:status => :both, :resources => {}}
    end

    #.........................................................................................................
    def method_missing(meth, *args, &blk)
      @items.send(meth, *args, &blk)
    end

  #### Roster
  end

#### AgentXmpp
end
