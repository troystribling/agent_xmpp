# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module REXML

  ####----------------------------------------------------------------------------------------------------
  class Element

    #.......................................................................................................
    def replace_element_text(e, t)
      el = first_element(e)
      if el.nil?
        el = REXML::Element.new(e)
        add_element(el)
      end
      el.text = t if t
      self
    end

    #.......................................................................................................
    def first_element(e)
      elements.to_a(e).first
    end

    #.......................................................................................................
    def first_element_text(e)
      el = first_element(e)
      el.nil? ? nil : el.text
    end

    #.......................................................................................................
    def typed_add(e)
      add(e)
    end

    #.......................................................................................................
    def import(xmlelement)
      if @name and @name != xmlelement.name
        raise "Trying to import an #{xmlelement.name} to a #{@name} !"
      end
      add_attributes(xmlelement.attributes.clone)
      @context = xmlelement.context
      xmlelement.each do |e|
        if e.kind_of? REXML::Element
          typed_add(e.deep_clone)
        elsif e.kind_of? REXML::Text
          add_text(e.value)
        else
          add(e.clone)
        end
      end
      self
    end

    #.......................................................................................................
    def self.import(xmlelement)
      self.new(xmlelement.name).import(xmlelement)
    end

    #.......................................................................................................
    def delete_elements(element)
      elements.delete_all(element)
    end

  #### Element
  end 

#### REXML
end 

