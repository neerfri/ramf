class Object
  
  flex_dynamic_members_finder do |instance, scope|
    instance.instance_variables.map{|v| v[1..-1].to_sym}
  end
  
  flex_members_evaluator do |instance, member|
    instance.send(member)
  end
  
  flex_dynamic_members_evaluator do |instance, member|
    case
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
  end

end