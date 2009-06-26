# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class X < XMPPElement
      name_xmlns 'x'
      force_xmlns true
    end

    #####-------------------------------------------------------------------------------------------------------
    module XParent

      #.......................................................................................................
      def x(wanted_xmlns=nil)
        if wanted_xmlns.kind_of? Class and wanted_xmlns.ancestors.include? XMPPElement
          wanted_xmlns = wanted_xmlns.new.namespace
        end
          each_element('x') { |x|
          if wanted_xmlns.nil? or wanted_xmlns == x.namespace
            return x
          end
        }
        nil
      end
      
    #### XParent
    end
    
  #### XMPP
  end

#### AgentXmpp
end
