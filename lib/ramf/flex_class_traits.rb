require 'rubygems'
require 'ruby-debug'
module RAMF
  #The term 'traits' is used to describe the defining characteristics of a class. (amf3 spec document section 3.12)
  class FlexClassTraits
    
    KNOWN_CLASSES = {}
    
    attr_reader :klass, :members, :name
    attr_accessor :transient_members, :amf_scope_options, :is_dynamic
    
    def initialize(klass,is_dynamic, options = {})
      @klass = klass
      @amf_scope_options = (s_w_r(klass) ? s_w_r(klass).flex_remoting.amf_scope_options.dup : {})
      @members = {}
      self.name= klass.name
      @is_dynamic = is_dynamic
      @defined_members = []
      @transient_members = options[:transient] || []
    end
    
    def name=(new_name)
      new_name = new_name.to_s
      if KNOWN_CLASSES[new_name] && KNOWN_CLASSES[new_name].name!=klass.name
        raise("An ActionScript class named '#{new_name}' already exists.")
      end
      KNOWN_CLASSES.delete(@name)
      @name = new_name
      KNOWN_CLASSES[new_name] = klass
    end
    
    def transient_members
      if s_w_r(klass)
        (@transient_members + s_w_r(klass).flex_remoting.transient_members).uniq
      else
        @transient_members
      end
    end
    
    def members(scope = :default)
      @members[scope] ||= find_members(scope)
    end
    
    def defined_members=(members)
      @defined_members = members.flatten.map {|v| v.to_sym}
    end
    
    def dynamic_members_finders
      @dynamic_members_finders ||= s_w_r(klass) ? s_w_r(klass).flex_remoting.dynamic_members_finders.dup : []
    end
    
    def dynamic_members(instance, scope = :default)
      members = dynamic_members_finders.map{|b| b.call(instance, scope)}.flatten.uniq
      members -= members(scope)
      members -= transient_members
      scope_opt = amf_scope_options[scope]
      except = scope_opt && scope_opt[:except] ? scope_opt[:except] : []
      members -= except
      members.inject({}) do |hash,member|
        value = case 
                  when instance.respond_to?(member)
                    instance.send(member)
                  when instance.instance_variable_defined?("@#{member}")
                    instance.instance_variable_get("@#{member}")
                  when instance.respond_to?(:[])
                    instance[member]
                  else
                    begin
                      instance.send(member)
                    rescue NoMethodError=>e
                      warn("***Warning: Couldn't find value from dynamic member #{member} in object #{instance.class.name}!")
                      nil
                    end
                end
        hash[member]=value
        hash
      end
    end
    
    ##############################################################
    private
        
    def find_members(scope)
      members = (s_w_r(klass) ? s_w_r(klass).flex_remoting.members(scope) : []) + @defined_members
      if (amf_scope_options[scope] && amf_scope_options[scope][:only])
        members = amf_scope_options[scope][:only]
      elsif klass.respond_to?(:flex_members)
        members = klass.flex_members
        members -= transient_members
        members -= amf_scope_options[scope][:except] if amf_scope_options[scope]
      end
      return members
    end
    
    #finds the first super class of <tt>klass</tt> the has remoting initialized
    def superclass_with_remoting(klass)
      if klass.superclass.nil? || klass.superclass.instance_variable_get("@flex_remoting")
        klass.superclass
      else
        superclass_with_remoting(klass.superclass)
      end
    end
    alias_method :s_w_r, :superclass_with_remoting
    
  end
end
