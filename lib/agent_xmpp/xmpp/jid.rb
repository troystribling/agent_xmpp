# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class JID

      #.......................................................................................................
      include Comparable

      #.......................................................................................................
      PATTERN = /^(?:([^@]*)@)??([^@\/]*)(?:\/(.*?))?$/

      #.......................................................................................................
      begin
        require 'idn'
        USE_STRINGPREP = true
      rescue LoadError
        USE_STRINGPREP = false
      end

      #.......................................................................................................
      def initialize(node = "", domain = nil, resource = nil)
        @resource = resource
        @domain = domain
        @node = node
        if @domain.nil? and @resource.nil? and @node
          @node, @domain, @resource = @node.to_s.scan(PATTERN).first
        end
        if USE_STRINGPREP
          @node = IDN::Stringprep.nodeprep(@node) if @node
          @domain = IDN::Stringprep.nameprep(@domain) if @domain
          @resource = IDN::Stringprep.resourceprep(@resource) if @resource
        else
          @node.downcase! if @node
          @domain.downcase! if @domain
        end
        raise ArgumentError, 'Node too long' if (@node || '').length > 1023
        raise ArgumentError, 'Domain too long' if (@domain || '').length > 1023
        raise ArgumentError, 'Resource too long' if (@resource || '').length > 1023
      end

      #.......................................................................................................
      def to_s
        s = @domain
        s = "#{@node}@#{s}" if @node
        s += "/#{@resource}" if @resource
        return s
      end

      #.......................................................................................................
      def strip
        JID.new(@node, @domain)
      end
      alias_method :bare, :strip

      #.......................................................................................................
      def strip!
        @resource = nil
        self
      end
      alias_method :bare!, :strip!

      #.......................................................................................................
      def hash
        return to_s.hash
      end

      #.......................................................................................................
      def eql?(o)
        to_s.eql?(o.to_s)
      end

      #.......................................................................................................
      def ==(o)
        to_s == o.to_s
      end

      #.......................................................................................................
      def <=>(o)
        to_s <=> o.to_s
      end

      #.......................................................................................................
      def node
        @node
      end

      #.......................................................................................................
      def node=(v)
        @node = v.to_s
        if USE_STRINGPREP
          @node = IDN::Stringprep.nodeprep(@node) if @node
        end
      end

      #.......................................................................................................
      def domain
        return nil if @domain.empty?
        @domain
      end

      #.......................................................................................................
      def domain=(v)
        @domain = v.to_s
        if USE_STRINGPREP
          @domain = IDN::Stringprep.nodeprep(@domain)
        end
      end

      #.......................................................................................................
      def resource
        @resource
      end

      #.......................................................................................................
      def resource=(v)
        @resource = v.to_s
        if USE_STRINGPREP
          @resource = IDN::Stringprep.nodeprep(@resource)
        end
      end

      #.......................................................................................................
      def JID::escape(jid)
        return jid.to_s.gsub('@', '%')
      end

      #.......................................................................................................
      def empty?
        to_s.empty?
      end

      #.......................................................................................................
      def stripped?
        @resource.nil?
      end      
      alias_method :bared?, :stripped?

    #### JID
    end
    
  #### XMPP
  end

#### AgentXmpp
end
