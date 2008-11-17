require 'rubygems'
module RAMF
  #The term 'traits' is used to describe the defining characteristics of a class. (amf3 spec document section 3.12)
  class FlexClassTraits
    
    KNOWN_CLASSES = {}
    
    def self.find_ruby_class(name)
#      RAILS_DEFAULT_LOGGER.info "name: #{name.to_s.inspect}"
#      RAILS_DEFAULT_LOGGER.info "KNOWN_CLASSES[name]:#{KNOWN_CLASSES[name.to_s].inspect}"
#      RAILS_DEFAULT_LOGGER.info "KNOWN_CLASSES:\n#{KNOWN_CLASSES.inspect}"
      Object.module_eval(KNOWN_CLASSES[name.to_s]) rescue nil
    end
    
    attr_reader :klass, :members, :name
    attr_accessor :transient_members, :amf_scope_options, :is_dynamic
    attr_accessor :dynamic_members_writer, :members_writer
    attr_accessor :dynamic_members_reader, :members_reader
    
    def initialize(klass,is_dynamic, options = {})
      @klass = klass
      @amf_scope_options = get_duplicate_from_super({}, :amf_scope_options)
      @members = {}
      self.name= klass.name
      @is_dynamic = is_dynamic
      @defined_members = []
      @transient_members = options[:transient] || []
      [:dynamic_members_writer, :members_writer, :dynamic_members_reader, :members_reader].each do |a|
        default = Proc.new{raise "No #{a} defined for #{klass}"}
        instance_variable_set("@#{a}", get_attribute_from_super(default, a))
      end
    end
    
    def name=(new_name)
      new_name = new_name.to_s
      if KNOWN_CLASSES[new_name] && KNOWN_CLASSES[new_name]!=klass.name
        raise("An ActionScript class named '#{new_name}' already exists.")
      end
      KNOWN_CLASSES.delete(@name)
      @name = new_name
      KNOWN_CLASSES[new_name] = klass.name
    end
    
    def transient_members
      (@transient_members + get_attribute_from_super([], :transient_members)).uniq
    end
    
    def members(scope = RAMF::Configuration::DEFAULT_SCOPE)
      @members[scope] ||= find_members(scope)
    end
    
    def defined_members=(members)
      @defined_members = members.flatten.map {|v| v.to_sym}
    end
    
    def dynamic_members_finders
      @dynamic_members_finders ||= get_duplicate_from_super([], :dynamic_members_finders)
    end
    
    def dynamic_members(instance, scope = RAMF::Configuration::DEFAULT_SCOPE)
      members = dynamic_members_finders.map{|b| b.call(instance, scope)}.flatten.uniq
      members -= members(scope)
      members -= transient_members
      scope_opt = amf_scope_options[scope]
      except = scope_opt && scope_opt[:except] ? scope_opt[:except] : []
      members -= except
      members.inject({}) do |hash,member|
        hash[member] = dynamic_members_reader.call(instance,member)
        hash
      end
    end
    
    ##############################################################
    private
        
    def find_members(scope)
      if (amf_scope_options[scope] && amf_scope_options[scope][:only])
        members = amf_scope_options[scope][:only]
        members -= transient_members
      else
        members = get_duplicate_from_super([], :members, scope) + @defined_members
        members += klass.flex_members if klass.respond_to?(:flex_members)
        members -= transient_members
        members -= amf_scope_options[scope][:except] if amf_scope_options[scope]
      end
      members
    end
    
    def get_duplicate_from_super(default, attribute, *args)
      get_attribute_from_super(default, attribute, *args).dup
    end
    
    
    def get_attribute_from_super(default, attribute, *args)
      klass.superclass ? klass.superclass.flex_remoting.send(attribute,*args) : default
    end
    
  end
end
