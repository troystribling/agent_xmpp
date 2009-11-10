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

    #####-------------------------------------------------------------------------------------------------------
    class XData < X

      #.....................................................................................................
      name_xmlns 'x', 'jabber:x:data'

      #.....................................................................................................
      def initialize(type=nil)
        super()
        self.type = type
      end

      #.....................................................................................................
      def fields
        elements.to_a('field')
      end

      #.....................................................................................................
      def items
        elements.to_a('item')
      end

      #.....................................................................................................
      def type
        attributes['type'].to_sym
      end

      #.....................................................................................................
      def type=(t)
        attributes['type'] = t.to_s
      end

      #.....................................................................................................
      def title
        first_element('title')
      end

      #.....................................................................................................
      def add_title(title)
        delete_elements('title')
        add_element(XDataTitle.new(title))
      end

      #.....................................................................................................
      def instructions
        elements.inject('instructions', []) {|f, xe| f << xe}
      end

      #.....................................................................................................
      def add_instructions(i)
        add(XDataInstructions.new(i))
      end

      #.....................................................................................................
      def add_fixed(val)
        add_field_with_value(nil, val, 'fixed')
      end

      #.....................................................................................................
      def add_hidden(var, val)
        add_field_with_value(var, val, 'hidden')
      end

      #.....................................................................................................
      def add_text_single(var, label=nil)
        add_field(var, label, 'text-single')
      end

      #.....................................................................................................
      def add_text_multi(var, label=nil)
        add_field(var, label, 'text-multi')
      end

      #.....................................................................................................
      def add_text_private(var, label=nil)
        add_field(var, label, 'text-private')
      end

      #.....................................................................................................
      def add_jid_single(var, label=nil)
        add_field(var, label, 'jid-single')
      end

      #.....................................................................................................
      def add_boolean(var, label=nil)
        add_field(var, label, 'boolean')
      end

      #.....................................................................................................
      def add_list_single(var, opts, label=nil, default=nil)
        field = XDataField.new(var, 'list-single')
        field.label = label if label
        field.options = opts
        field.values = [default] if default
        self << field
      end

      #.....................................................................................................
      def add_field_with_value(var, value, type=nil)
        field = XDataField.new(var, type)
        field.values = value
        self << field
      end

      #.....................................................................................................
      def to_native 
        f, i = fields, items   
        if f.length.eql?(1) and i.length.eql?(0)
          to_scalar(f.first.values)
        elsif f.length > 1 and i.length.eql?(0)  
          to_hash(f)
        elsif i.length > 0 
           to_array_of_hashes(i)
        else
          nil
        end
      end

      #.....................................................................................................
      def to_params
        to_hash(fields)
      end
      
      #.....................................................................................................
      def to_x_data
        self
      end

      #.....................................................................................................
      # private
      #.....................................................................................................
      def to_scalar(vals)
        vals.length.eql?(1) ? vals.first : vals
      end
      
      #.....................................................................................................
      def to_hash(flds)
        flds.inject({}) {|h,f| h[f.var] = to_scalar(f.values); h}
      end

      #.....................................................................................................
      def to_array_of_hashes(itms)
        itms.map{|i| to_hash(i.fields)}
      end

      #.....................................................................................................
      def add_field(var, label, type=nil)
        field = XDataField.new(var, type)
        field.label = label if label
        self << field
      end
      
      #.....................................................................................................
      private :to_scalar, :to_hash, :to_array_of_hashes, :add_field
      
    end

    #####-------------------------------------------------------------------------------------------------------
    class XDataTitle < Element

      #.....................................................................................................
      name_xmlns 'title', 'jabber:x:data'

      #.....................................................................................................
      def initialize(title=nil)
        super()
        add_text(title)
      end

      #.....................................................................................................
      def to_s
        text.to_s
      end

      #.....................................................................................................
      def title
        text
      end
      
    end

    #####-------------------------------------------------------------------------------------------------------
    class XDataInstructions < Element

      #.....................................................................................................
      name_xmlns 'instructions', 'jabber:x:data'

      #.....................................................................................................
      def initialize(instructions=nil)
        super()
        add_text(instructions)
      end

      #.....................................................................................................
      def to_s
        text.to_s
      end

      #.....................................................................................................
      def instructions
        text
      end
    end

    #####-------------------------------------------------------------------------------------------------------
    class XDataField < Element

      #.....................................................................................................
      name_xmlns 'field', 'jabber:x:data'
      xmpp_attribute :label, :var
      xmpp_attribute :type, :sym => true

      #.....................................................................................................
      def initialize(var=nil, type=nil)
        super()
        self.var = var if var
        self.type = type if type
      end

      #.....................................................................................................
      def required?
        res = false
        each_element('required') { res = true }
        res
      end

      #.....................................................................................................
      def required=(r)
        delete_elements('required')
        add REXML::Element.new('required') if r
      end

      #.....................................................................................................
      def values
        elements.inject('value', []){|r,v| r << v.text}
      end

      #.....................................................................................................
      def values=(ary)
        delete_elements('value')
        [ary].flatten.each {|v| add(REXML::Element.new('value')).text = v}
      end

      #.....................................................................................................
      def options
        elements.inject('option',{}) do |r, e|
          value = nil
          value = (ve = first_element('value')).nil? ? nil : ve.text
          r[value] = e.attributes['label'] if value
          r 
        end
      end

      #.....................................................................................................
      def options=(opts)
        opts = opts.inject({}){|h,v| h.update(v => v.to_s.gsub(/_/,' '))} if opts.kind_of?(Array)
        delete_elements('option')
        opts.each do |value,label|
          o = add(REXML::Element.new('option'))
          o.attributes['label'] = label
          o.add(REXML::Element.new('value')).text = value.to_s
        end
      end
    end

    #####-------------------------------------------------------------------------------------------------------
    class XDataReported < Element

      #.....................................................................................................
      name_xmlns 'reported', 'jabber:x:data'

      #.....................................................................................................
      def fields
        elements.to_a('field')
      end

      #.....................................................................................................
      def add_field(var)
        self << XDataField.new(var)
      end
    end

    #####-------------------------------------------------------------------------------------------------------
    class XDataItem < Element

      #.....................................................................................................
      name_xmlns 'item', 'jabber:x:data'

      #.....................................................................................................
      def fields
        elements.to_a('field')
      end

      #.....................................................................................................
      def add_field_with_value(var, value, type=nil)
        field = XDataField.new(var, type)        
        field.values = value
        self << field
      end

    #### XDataItem
    end 

  #### XMPP
  end

#### AgentXmpp
end
