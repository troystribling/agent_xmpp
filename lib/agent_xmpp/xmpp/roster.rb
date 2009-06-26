# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    module Roster

      #####-------------------------------------------------------------------------------------------------------
      class IqQueryRoster < IqQuery

        #.......................................................................................................
        name_xmlns 'query', 'jabber:iq:roster'

        #.......................................................................................................
        def each(&block)
          each_element { |item|
            yield(item) if item.kind_of?(RosterItem)
          }
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
      class RosterItem < XMPPElement

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
      
    #### IqQueryRoster  
    end
    
  #### XMPP
  end

#### AgentXmpp
end
 