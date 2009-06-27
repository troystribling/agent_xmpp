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
      if t
        el.text = t
      end
      self
    end

    #.......................................................................................................
    def first_element(e)
      each_element(e) { |el| return el }
      return nil
    end

    #.......................................................................................................
    def first_element_text(e)
      el = first_element(e)
      if el
        return el.text
      else
        return nil
      end
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
      while(delete_element(element)) do end
    end

    #.......................................................................................................
    def ==(o)
      return false unless self.kind_of? REXML::Element
      if o.kind_of? REXML::Element
      elsif o.kind_of? String
        begin
          o = REXML::Document.new(o).root
        rescue REXML::ParseException
          return false
        end
      else
        return false
      end

      return false unless name == o.name

      attributes.each_attribute do |attr|
        return false unless attr.value == o.attributes[attr.name]
      end

      o.attributes.each_attribute do |attr|
        return false unless attributes[attr.name] == attr.value
      end

      children.each_with_index do |child,i|
        return false unless child == o.children[i]
      end

      return true
    end

  #### Element
  end 

#### REXML
end 

