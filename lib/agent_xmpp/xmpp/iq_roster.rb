# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class IqRoster < IqQuery

      #####-------------------------------------------------------------------------------------------------------
      class << self
        
        #.........................................................................................................
        def get(pipe)
          Send(new_rosterget) do |r|
            if r.type == :result and r.kind_of?(Xmpp::Iq)
              [r.query.elements.collect{|i| pipe.broadcast_to_delegates(:did_receive_roster_item, pipe, i)}, \
                pipe.broadcast_to_delegates(:did_receive_all_roster_items, pipe)].smash
            elsif r.type.eql?(:error)
              raise AgentXmppError, "roster request failed"
            end
          end
        end

        #.........................................................................................................
        def add(roster_item_jid, pipe)
          request = new_rosterset
          request.query.add(Xmpp::RosterItem.new(roster_item_jid))
          Send(request) do |r|
            if r.type == :result and r.kind_of?(Xmpp::Iq)
              [Send(Xmpp::Presence.new.set_type(:subscribe).set_to(roster_item_jid)), \
                pipe.broadcast_to_delegates(:did_acknowledge_add_roster_item, pipe, r, roster_item_jid)].smash
            elsif r.type.eql?(:error)
              AgentXmpp.logger.error "ERROR ADDING ROSTER ITEM: #{roster_item_jid}"
              pipe.broadcast_to_delegates(:did_receive_add_roster_item_error, pipe, r, roster_item_jid)
            end
          end
        end

        #.........................................................................................................
        def remove(roster_item_jid, pipe)
          request = new_rosterset
          request.query.add(Xmpp::RosterItem.new(roster_item_jid, nil, :remove))
          Send(request) do |r|
            if r.type == :result and r.kind_of?(Xmpp::Iq)
              pipe.broadcast_to_delegates(:did_acknowledge_remove_roster_item, pipe, r, roster_item_jid)
            elsif r.type.eql?(:error)
              AgentXmpp.logger.error "ERROR REMOVING ROSTER ITEM: #{roster_item_jid}"
              pipe.broadcast_to_delegates(:did_receive_remove_roster_item_error, pipe, r, roster_item_jid)
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
      name_xmlns 'query', 'jabber:iq:roster'

      #.......................................................................................................
      def each(&block)
        each_element {|item| yield(item) if item.kind_of?(RosterItem)}
      end

      #.......................................................................................................
      def [](jid)
        each { |item|
          return(item) if item.jid == jid
        }
        nil
      end

      #.......................................................................................................
      def to_a
        a = []
        each { |item|
          a.push(item)
        }
        a
      end

      #.......................................................................................................
      def receive_iq(iq, filter=true)
        if filter && (((iq.type != :set) && (iq.type != :result)) || (iq.queryns != 'jabber:iq:roster'))
          return
        end

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
        (a = attributes['jid']) ? JID.new(a) : nil
      end

      #.......................................................................................................
      def jid=(val)
        attributes['jid'] = val.nil? ? nil : val.to_s
      end

      #.......................................................................................................
     def subscription
        attributes['subscription'].to_sym
      end

      #.......................................................................................................
      def subscription=(val)
        attributes['subscription'] = val.to_s
      end

      #.......................................................................................................
      def ask
        case attributes['ask']
          when 'subscribe' then :subscribe
          else nil
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
        result = []
        each_element('group') { |group|
          result.push(group.text)
        }
        result.uniq
      end

      #.......................................................................................................
      def groups=(ary)
        delete_elements('group')
        ary.uniq.each { |group|
          add_element('group').text = group
        }
      end
      
    #### RosterItem
    end
    
  #### XMPP
  end

#### AgentXmpp
end
 