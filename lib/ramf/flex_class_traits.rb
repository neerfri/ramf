module RAMF
  #The term 'traits' is used to describe the defining characteristics of a class. (amf3 spec document section 3.12)
  class FlexClassTraits
    
    KNOWN_CLASSES = {}
    
    attr_reader :klass, :members, :name
    attr_accessor :transient_members, :amf_scope_options, :is_dynamic
    
    def initialize(klass,is_dynamic, options = {})
      @klass = klass
      @amf_scope_options = {}
      @members = {}
      self.name= klass.name
      @is_dynamic = is_dynamic
      @defined_members = []
      @transient_members = options[:transient] || []
    end
    
    def name=(new_name)
      new_name = new_name.to_s
      raise("An ActionScript with that name already exists.") if KNOWN_CLASSES[new_name] && new_name!=@name
      KNOWN_CLASSES.delete(@name)
      @name = new_name
      KNOWN_CLASSES[new_name] = klass
    end
    
    def members(scope = :default)
      @members[scope] ||= find_members(scope)
    end
    
    def defined_members=(members)
      @defined_members = members.flatten.map {|v| v.to_sym}
    end
    
    ##############################################################
    private
        
    def find_members(scope)
      members = @defined_members
      if (amf_scope_options[scope] && amf_scope_options[scope][:only])
        members = amf_scope_options[scope][:only]
      elsif klass.respond_to?(:flex_members)
        members = klass.flex_members
        members -= transient_members
        members -= amf_scope_options[scope][:except] if amf_scope_options[scope]
      end
      return members
    end
    
  end
end