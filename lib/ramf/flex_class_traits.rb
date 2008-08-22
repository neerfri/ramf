module RAMF
  #The term 'traits' is used to describe the defining characteristics of a class. (amf3 spec document section 3.12)
  class FlexClassTraits
    
    attr_reader :klass, :is_dynamic, :members
    attr_accessor :transient_members, :amf_scope_options, :name
    
    def initialize(klass,is_dynamic, options = {})
      @klass = klass
      @amf_scope_options = {}
      @members = {}
      @name= klass.name
      @is_dynamic = is_dynamic
      @defined_members = []
      @transient_members = options[:transient] || []
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
