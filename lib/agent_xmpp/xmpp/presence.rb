# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class Presence < XMPPStanza

      #.......................................................................................................
      name_xmlns 'presence', 'jabber:client'
      force_xmlns true

      #.......................................................................................................
      include Comparable
      include XParent

      #.......................................................................................................
      def initialize(show=nil, status=nil, priority=nil)
        super()
        set_show(show) if show
        set_status(status) if status
        set_priority(priority) if priority
      end

      #.......................................................................................................
      def type
        case super
          when 'error' then :error
          when 'probe' then :probe
          when 'subscribe' then :subscribe
          when 'subscribed' then :subscribed
          when 'unavailable' then :unavailable
          when 'unsubscribe' then :unsubscribe
          when 'unsubscribed' then :unsubscribed
          else nil
        end
      end

      #.......................................................................................................
      def type=(val)
        case val
          when :error then super('error')
          when :probe then super('probe')
          when :subscribe then super('subscribe')
          when :subscribed then super('subscribed')
          when :unavailable then super('unavailable')
          when :unsubscribe then super('unsubscribe')
          when :unsubscribed then super('unsubscribed')
          else super(nil)
        end
      end

      #.......................................................................................................
      def set_type(val)
        self.type = val
        self
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
      def set_show(val)
        self.show = val
        self
      end

      #.......................................................................................................
      def status
        first_element_text('status')
      end

      #.......................................................................................................
      def status=(val)
        if val.nil?
          delete_element('status')
        else
          replace_element_text('status', val)
        end
      end

      #.......................................................................................................
      def set_status(val)
        self.status = val
        self
      end

      #.......................................................................................................
      def priority
         e = first_element_text('priority')
        if e
          return e.to_i
        else
          return nil
        end
      end

      #.......................................................................................................
      def priority=(val)
        if val.nil?
          delete_element('priority')
        else
          replace_element_text('priority', val)
        end
      end

      #.......................................................................................................
      def set_priority(val)
        self.priority = val
        self
      end

      #.......................................................................................................
      def <=>(o)
        if priority.to_i == o.priority.to_i
          cmp_interest(o)
        else
          priority.to_i <=> o.priority.to_i
        end
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
          if o.type.nil?
            PRESENCE_STATUS[show] <=> PRESENCE_STATUS[o.show]
          else
            return -1
          end
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
