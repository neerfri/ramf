class Object
  def flex_dynamic_members(scope = :default)
    if self.respond_to?(:flex_dynamic_members_for) 
      self.flex_dynamic_members_for(scope)
    else
      dynamic_members = self.instance_variables.map {|v| v[1..-1].to_sym}
      dynamic_members -= self.class.flex_reflection.members(scope)
      dynamic_members -= self.class.flex_reflection.transient_members
      scope_opt = self.class.flex_reflection.amf_scope_options[scope]
      except = scope_opt && scope_opt[:except] ? scope_opt[:except] : []
      dynamic_members -= except
      dynamic_members.inject({}) {|member,hash| hash[member]=self.send(member.to_sym)}
    end
  end
end

module FlexRemotingBaseExtensions
  
  #returns the FlexReflection object of the class,
  #if it doesn't exist, it will create one.
  #
  # class Car
  #   @@my_flex_remoting = flex_remoting
  #   #Why would you be doing that ???
  # end
  def flex_remoting
    @flex_remoting ||= RAMF::FlexReflection.new(self, true)
  end
  
  #This method defines members that are transient, which means
  #they will not be sent by amf, and will be ignored if received from amf.
  #For Exmple:
  # class User
  #   flex_remoting_transient :encrypted_password, :encription_salt
  # end
  #this will define <tt>:encrypted_password, :encription_salt</tt> not
  #to be sent over amf.
  #make sure they are not important to represent the 
  #object when it come from flex.
  #Not for exmple if you omit an attribute in active record and save it
  #will be updated to the default value(nil?).
  def flex_remoting_transient(*args)
    flex_remoting.transient_members += args.map {|v| v.to_s}
  end
  
  #defines members for a specific scope.
  #For exmple:
  # class User
  #   flex_remoting_scope :limited, :except=>[:phone,:email]
  #   flex_remoting_scope :private, :only=>[:fullname, :nickname]
  # end
  #this will set :phone and :email attributes not to be sent
  #when using <tt> render :amf=>@user, :scope=>:limited </tt>.
  #
  #it will also set only :fullname and :nickname to be sent when
  #using <tt> render :amf=>@user_list, :scope=>:private </tt> 
  #
  #Use can only set either :except or :only for each scope.
  def flex_remoting_scope(scope, options)
    raise "only & except" if options[:only] && options[:except]
    flex_remoting.amf_scope_options[scope] = options
  end
  
  #define the action script name of the class (or what they set 
  #in RemoteAlias('') )
  # class SomeRubyClass
  #   flex_alias_name :SomeActionScriptClass
  # end
  #this will make the client side(flex) receive a class 
  #named SomeActionScriptClass
  def flex_alias(class_name)
    flex_remoting.name = class_name.to_s
  end
end