##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class Roster

    #.........................................................................................................
    def initialize(jid, contacts)
      @items = Hash.new{|hash, key| hash[key] = {:activated => false, :resources => {}}}
      contacts.each{|c| @items[c]}
      @items[jid.bare.to_s] = {:activated => true, :resources => {}}
    end

    #.........................................................................................................
    def method_missing(meth, *args, &blk)
      @items.send(meth, *args, &blk)
    end

  #### Roster
  end

#### AgentXmpp
end
