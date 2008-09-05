class Object
  
  def flex_dynamic_members(scope = :default)
    if self.respond_to?(:flex_dynamic_members_for) 
      self.flex_dynamic_members_for(scope)
    else
      dynamic_members = self.instance_variables.map {|v| v[1..-1].to_sym}
      dynamic_members -= self.class.flex_remoting.members(scope)
      dynamic_members -= self.class.flex_remoting.transient_members
      scope_opt = self.class.flex_remoting.amf_scope_options[scope]
      except = scope_opt && scope_opt[:except] ? scope_opt[:except] : []
      dynamic_members -= except
      dynamic_members.inject({}) do |hash,member| 
        hash[member]=(self.respond_to?(member) ? self.send(member) : self.instance_variable_get("@#{member}"))
        hash
      end
    end
  end
end