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
        elements.to_a('x').select{|x| wanted_xmlns.nil? or wanted_xmlns == x.namespace}.first
      end
      
    #### XParent
    end
    
  #### XMPP
  end

#### AgentXmpp
end
