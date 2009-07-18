# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class Presence < Stanza

      #.......................................................................................................
      include Comparable
      include XParent

      #.......................................................................................................
      name_xmlns 'presence', 'jabber:client'

      #####-------------------------------------------------------------------------------------------------------
      class << self
        
        #.........................................................................................................
        def accept(contact_jid)
          pres = Xmpp::Presence.new
          pres.type = :subscribed
          pres.to = contact_jid  
          Send(pres)
        end

        #.........................................................................................................
        def decline(contact_jid)
          pres = Xmpp::Presence.new
          pres.type = :unsubscribed
          pres.to = contact_jid      
          Send(pres)
        end

        #.........................................................................................................
        def subscribe(contact_jid)
          pres = Xmpp::Presence.new
          pres.type = :subscribe
          pres.to = contact_jid
          Send(pres)
        end
        
      #### self
      end
      
      #.......................................................................................................
      def initialize(show=nil, status=nil, priority=nil)
        super()
        self.show = show if show
        self.status = status if status
        self.priority = priority if priority
      end

      #.......................................................................................................
     def show
        e = first_element('show')
        text = e ? e.text : nil
        text.to_sym
      end

      #.......................................................................................................
      def show=(val)
        xe = first_element('show')
        if xe.nil?
          xe = add_element('show')
        end
       if text.nil?
          delete_element(xe)
        else
          xe.text = text
        end
      end

      #.......................................................................................................
      def status
        first_element_text('status')
      end

      #.......................................................................................................
      def status=(val)
        val.nil? ? delete_element('status') : replace_element_text('status', val)
      end

      #.......................................................................................................
      def priority
        (e = first_element_text('priority')).nil? ? nil : e.to_i
      end

      #.......................................................................................................
      def priority=(val)
        val.nil? ? delete_element('priority') : replace_element_text('priority', val)
      end

      #.......................................................................................................
      def <=>(o)
        priority.to_i == o.priority.to_i ? cmp_interest(o) : priority.to_i <=> o.priority.to_i
      end

      #.......................................................................................................
      PRESENCE_STATUS = { :chat => 4,
                          nil => 3,
                          :dnd => 2,
                          :away => 1,
                          :xa => 0,
                          :unavailable => -1,
                          :error => -2 }
      #.......................................................................................................
      def cmp_interest(o)
        if type.nil?
          o.type.nil? ? PRESENCE_STATUS[show] <=> PRESENCE_STATUS[o.show] : -1
        elsif o.type.nil?
          return 1
        else
          return 0
        end
      end

    #### Presence
    end
    
  #### XMPP
  end

#### AgentXmpp
end
