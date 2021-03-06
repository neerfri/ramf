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
      
      def method_missing(method_name,*args,&block)
        method_name = method_name.to_s 
        if method_name[method_name.length-1,1] == "="
          self["#{method_name[0,method_name.length-1]}".to_sym] = args.first
        else
          self["#{method_name}".to_sym]
        end
    end
    
    def to_params
      self.inject({}) do |m,pair|
        key = pair.first
        object = pair.last
        case object
          when Hash, Numeric, String, TrueClass, FalseClass, \
               NilClass, Array, Symbol, Date, Time, IO, Tempfile, StringIO
            m.merge({key=>object})
          else
            flex_remoting = object.class.flex_remoting
            hash = {}
            flex_remoting.members.each do |member|
              hash[member] = flex_remoting.members_reader.call(object,member)
            end
            hash.merge!(flex_remoting.dynamic_members(object)) if flex_remoting.is_dynamic
            m.merge! key=>hash
        end
      end
    end
      
      
#      def flex_dynamic_members(scope = :default)
#        self.keys.inject({}) {|mem, key| mem[key.to_s] = self[key]; mem}
#      end
      
    end
  end
end
