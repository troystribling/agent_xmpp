# Original from XMPP4R - XMPP Library for Ruby Website::http://home.gna.org/xmpp4r/
##############################################################################################################
module AgentXmpp

  #####-------------------------------------------------------------------------------------------------------
  module Xmpp

    #####-------------------------------------------------------------------------------------------------------
    class Element < REXML::Element

      #####-------------------------------------------------------------------------------------------------------
      class << self
        
        #.......................................................................................................
        def name_xmlns(name, xmlns=nil)
          @@name_xmlns_classes[[name, xmlns]] = self
        end

        #.......................................................................................................
        def force_xmlns(force)
          @@force_xmlns = force
        end

        #.......................................................................................................
        def force_xmlns?
          @@force_xmlns
        end

        #.......................................................................................................
        def name_xmlns_for_class(klass)
          klass.ancestors.each do |klass1|
            @@name_xmlns_classes.each do |name_xmlns,k|
              if klass1 == k
                return name_xmlns
              end
            end
          end
          raise NoNameXmlnsRegistered.new(klass)
        end

        #.......................................................................................................
        def class_for_name_xmlns(name, xmlns)
          if @@name_xmlns_classes.has_key? [name, xmlns]
            @@name_xmlns_classes[[name, xmlns]]
          elsif @@name_xmlns_classes.has_key? [name, nil]
            @@name_xmlns_classes[[name, nil]]
          else
            REXML::Element
          end
        end

        #.......................................................................................................
        def import(element)
          klass = class_for_name_xmlns(element.name, element.namespace)
          if klass != self and klass.ancestors.include?(self)
            klass.new.import(element)
          else
            self.new.import(element)
          end
        end
        
      #### self
      end
      
      #.......................................................................................................
      @@name_xmlns_classes = {}
      @@force_xmlns = false
      
      #.......................................................................................................
      def initialize(*arg)
        if arg.empty?
          name, xmlns = self.class::name_xmlns_for_class(self.class)
          super(name)
          if self.class::force_xmlns?
            add_namespace(xmlns)
          end
        else
          super
        end
      end

      #.......................................................................................................
      def typed_add(element)
        if element.kind_of? REXML::Element
          element_ns = (element.namespace.to_s == '') ? namespace : element.namespace

          klass = Element::class_for_name_xmlns(element.name, element_ns)
          if klass != element.class
            element = klass.import(element)
          end
        end

        super(element)
      end

      #.......................................................................................................
      def parent=(new_parent)
        if parent and parent.namespace('') == namespace('') and attributes['xmlns'].nil?
          add_namespace parent.namespace('')
        end
        super
        if new_parent and new_parent.namespace('') == namespace('')
          delete_namespace
        end
      end

      #.......................................................................................................
      def clone
        cloned = self.class.new
        cloned.add_attributes self.attributes.clone
        cloned.context = @context
        cloned
      end

      #.......................................................................................................
      def xml_lang
        attributes['xml:lang']
      end

      #.......................................................................................................
      def xml_lang=(l)
        attributes['xml:lang'] = l
      end

      #.......................................................................................................
      def set_xml_lang(l)
        self.xml_lang = l
        self
      end
      
      #.....................................................................................................
      def <<(child)
        add(child)
        self
      end
      
    #### Element
    end  
      
  #### XMPP
  end

#### AgentXmpp
end
