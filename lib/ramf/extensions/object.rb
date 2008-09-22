class Object
  
  flex_dynamic_members_finder do |instance, scope|
    instance.instance_variables.map{|v| v[1..-1].to_sym}
  end
end