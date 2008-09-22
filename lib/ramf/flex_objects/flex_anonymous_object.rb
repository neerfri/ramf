module RAMF
  module FlexObjects
    
    #This class is used to create objects that are anonymous flex objects.
    #these objects are very much like a ruby hash but their attributes can be accessed
    #via methods as well.
    #
    # some_object = RAMF::FlexObjects::FlexAnonymousObject.new
    # => {}
    # some_object.my_attribute = "Wow !"
    # => "Wow !"
    # some_object
    # => {:my_attribute=>"Wow !"}
    # some_object.my_attribute == some_object[:my_attribute]
    # => true
    #
    class FlexAnonymousObject < Hash
      
      flex_alias ""
      
      flex_dynamic_members_finder do |instance, scope|
        instance.keys
      end
      
      def method_missing(method_name,*args,&block)
        method_name = method_name.to_s 
        if method_name[method_name.length-1,1] == "="
          self["#{method_name[0,method_name.length-1]}".to_sym] = args.first
        else
          self["#{method_name}".to_sym]
        end
      end
      
      
      def flex_dynamic_members(scope = :default)
        self.keys.inject({}) {|mem, key| mem[key.to_s] = self[key]; mem}
      end
      
    end
  end
end
