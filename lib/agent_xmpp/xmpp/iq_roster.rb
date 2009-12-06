# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class IqRoster < IqQuery

      #.......................................................................................................
      name_xmlns 'query', 'jabber:iq:roster'

      #####-------------------------------------------------------------------------------------------------------
      class << self
        
        #.........................................................................................................
        def get(pipe)
          Send(new_rosterget) do |r|
            if r.type == :result and r.kind_of?(Xmpp::Iq)
              pipe.broadcast_to_delegates(:on_roster_result, pipe, r)
            elsif r.type.eql?(:error)
              raise AgentXmppError, "roster request failed"
            end
          end
        end

        #.........................................................................................................
        def update(pipe, roster_item_jid, groups=nil)
          request = new_rosterset
          item = Xmpp::RosterItem.new(roster_item_jid)
          item.groups = groups unless groups.nil?
          request.query.add(item)
          Send(request) do |r|
            if r.type == :result and r.kind_of?(Xmpp::Iq)
              pipe.broadcast_to_delegates(:on_update_roster_item_result, pipe, r)
            elsif r.type.eql?(:error)
              pipe.broadcast_to_delegates(:on_update_roster_item_error, pipe, roster_item_jid)
            end
          end
        end

        #.........................................................................................................
        def remove(pipe, roster_item_jid)
          request = new_rosterset
          request.query.add(Xmpp::RosterItem.new(roster_item_jid, nil, :remove))
          Send(request) do |r|
            if r.type == :result and r.kind_of?(Xmpp::Iq)
              pipe.broadcast_to_delegates(:on_remove_roster_item_result, pipe, r)
            elsif r.type.eql?(:error)
              pipe.broadcast_to_delegates(:on_remove_roster_item_error, pipe, roster_item_jid)
            end
          end
        end
        
      private 
      
        #.......................................................................................................
        def new_rosterget
          iq = Iq.new(:get)
          query = IqQuery.new
          query.add_namespace('jabber:iq:roster')
          iq.add(query)
          iq
        end
        
        #.......................................................................................................
        def new_rosterset
          iq = Iq.new(:set)
          query = IqQuery.new
          query.add_namespace('jabber:iq:roster')
          iq.add(query)
          iq
        end
        
      #### self
      end

      #.......................................................................................................
      def each(&block)
        each_element {|item| yield(item) if item.kind_of?(RosterItem)}
      end

      #.......................................................................................................
      def [](jid)
        each{|item| return(item) if item.jid == jid}
        nil
      end

      #.......................................................................................................
      def to_a
        a = []
        each{|item| a.push(item)}
        a
      end

      #.......................................................................................................
      def receive_iq(iq, filter=true)
        return if filter && (((iq.type != :set) && (iq.type != :result)) || (iq.queryns != 'jabber:iq:roster'))
        import(iq.query)
      end

      #.......................................................................................................
      def inspect
        jids = to_a.collect { |item| item.jid.inspect }
        jids.join(', ')
      end
      
    #### IqQueryRoster
    end

    #####-------------------------------------------------------------------------------------------------------
    class RosterItem < Element

      #.......................................................................................................
      name_xmlns 'item', 'jabber:iq:roster'
      xmpp_attribute :subscription, :sym => true

      #.......................................................................................................
      def initialize(jid=nil, iname=nil, subscription=nil, ask=nil)
        super()
        self.jid = jid
        self.iname = iname if iname
        self.subscription = subscription if subscription
        self.ask = ask if ask
      end

      #.......................................................................................................
      def iname
        attributes['name']
      end

      #.......................................................................................................
      def iname=(val)
        attributes['name'] = val
      end

      #.......................................................................................................
      def jid
        (a = attributes['jid']) ? Jid.new(a) : nil
      end

      #.......................................................................................................
      def jid=(val)
        attributes['jid'] = val.nil? ? nil : val.to_s
      end

      #.......................................................................................................
      def ask
        case attributes['ask']
          when 'subscribe' then :subscribe
          else :none
        end
      end

      #.......................................................................................................
      def ask=(val)
        case val
          when :subscribe then attributes['ask'] = 'subscribe'
          else attributes['ask'] = nil
        end
      end

      #.......................................................................................................
      def groups
        elements.inject('group', []) {|r, g| r << g.text}.uniq
      end

      #.......................................................................................................
      def groups=(ary)
        delete_elements('group')
        ary.uniq.each{|group| add_element('group').text = group}
      end
      
    #### RosterItem
    end
    
  #### XMPP
  end

#### AgentXmpp
end
 