module RAMF
  #The term 'traits' is used to describe the defining characteristics of a class. (amf3 spec document section 3.12)
  class FlexClassTraits
    
    attr_reader :klass, :name, :is_dynamic, :members
    attr_accessor :transient_members, :amf_scope_options
    
    def initialize(klass,is_dynamic, options = {})
      @klass = klass
      @amf_scope_options = {}
      @members = {}
      @name= klass.name
      @is_dynamic = klass.respond_to?(:flex_dynamic?) ? klass.flex_dynamic? : true
#      @transient_members = klass.respond_to?(:flex_transient_members) ? klass.flex_transient_members : []
      @transient_members = options[:transient] ? options[:transient] : []
#      puts "initialized flex reflection for: #{@name}"
    end
    
    def name=(val)
      if val=='' || val=='Object'
        @name = ''
      else
        @name = val
      end
    end
    
    def members(scope = :default)
      @members[scope] ||= find_members(scope)
    end
    
    ##############################################################
    private
        
    def find_members(scope)
      members = []
#      puts amf_scope_options.inspect
      if (amf_scope_options[scope] &&
          amf_scope_options[scope][:only])
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
