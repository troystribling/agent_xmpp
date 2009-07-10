# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class X < Element
      name_xmlns 'x'
    end

    #####-------------------------------------------------------------------------------------------------------
    module XParent

      #.......................................................................................................
      def x(wanted_xmlns=nil)
        if wanted_xmlns.kind_of? Class and wanted_xmlns.ancestors.include? Element
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
