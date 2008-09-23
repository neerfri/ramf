class Hash
  
  flex_remoting.instance_variable_set("@name","")
  
  flex_dynamic_members_finder do |instance, scope|
    instance.keys
  end
end