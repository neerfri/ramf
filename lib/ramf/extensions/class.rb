class Class
  
  #returns the FlexReflection object of the class,
  #if it doesn't exist, it will create one.
  #
  # class Car
  #   @@my_flex_remoting = flex_remoting
  #   #Why would you be doing that ???
  # end
  def flex_remoting
    @flex_remoting ||= RAMF::FlexClassTraits.new(self, true, :transient=>[:flex_remoting])
  end
  
  #This method defines members that are transient, which means
  #they will not be sent by amf, and will be ignored if received from amf.
  #For Exmple:
  # class User
  #   flex_remoting_transient :encrypted_password, :encription_salt
  # end
  #this will define <tt>:encrypted_password, :encription_salt</tt> not
  #to be sent over amf.
  #Make sure they are not important to represent the object when it comes from amf.
  def flex_remoting_transient(*args)
    flex_remoting.transient_members += args.map {|v| v.to_sym}
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
  
  #This method defines members that are fixed with the object, which means
  #they will use to define the class's signature during serialization.
  #For Exmple:
  # class User
  #   flex_remoting_members :great_attribute, :important_attribute
  # end
  #this will define <tt>:great_attribute, :important_attribute</tt> to 
  #always be sent over amf.
  #
  #Note that some classes can use other mechanisms to find sealed members,
  #this is the most simple way to do so.
  
  def flex_remoting_members(*members)
    flex_remoting.defined_members = members
  end
end