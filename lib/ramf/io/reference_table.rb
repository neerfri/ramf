module RAMF
  module IO
    #This class provides all the reference tables for the serializer and deserializer.
    #
    #The work it performs is a bit tricky to understand.
    #I will make an attemt to explain the various use cases by examples,
    #the examples are given for object reference table but are the same for 
    #classes and strings as well.
    #
    #=Serialization Process:
    #
    #store :object, object
    #
    #this will store the object <tt>object</tt> in the reference table and will assign a number to it (auto incremented)
    #the object <tt>object</tt> will be used as the key while the number will be the value.
    #the number for the object can be fetched using:
    #
    #retrive :object, object
    #
    #=Deserialization Process:
    #
    #store :object do
    #  #build the object you wish to store...
    #  object
    #end
    #
    #this will store the object <tt>object</tt> in the reference table and will assign a number to it(auto incremented)
    #the object <tt>object</tt> will be used as the value and the number assigned will be used as key.
    #so if at any later time you will encounter a reference to an object you can just pull that object using:
    #
    #retrive :object, 5
    #
    class ReferenceTable
      
      def initialize
        @object_references = {}
        @class_references = {}
        @string_references = {}
      end
      
      def store(group,fixed_key = nil, &block)
        raise "must give a block or a fixed_key to store" unless block_given? || fixed_key
        var_name = "@#{group.to_s}_references"
        reference_table = instance_variable_get(var_name)
        current_index = reference_table.length
        key = fixed_key ? fixed_key : current_index
        reference_table[key] = PlaceHolder.new if !reference_table.has_key?(key) #put a stub place holder in case we need it
        reference_table[key] = (!block_given? ? current_index : block.call)
      end
      
      def retrive(group, key)
        var_name = "@#{group.to_s}_references"
        reference_table = instance_variable_get(var_name)
        reference_table[key]
      end

      def key_of(group, value)
        var_name = "@#{group.to_s}_references"
        reference_table = instance_variable_get(var_name)
        pair = reference_table.find{|k,v| v == value}
        pair ? pair.first : nil
      end
    end
    
    module ReferenceTableUser
      
      def register_reference_table(reference_table = nil)
        @reference_table = reference_table  || ReferenceTable.new
      end
      
      def store(*args, &block)
        @reference_table.store(*args, &block)
      end
      
      def retrive(*args, &block)
        @reference_table.retrive(*args, &block)
      end

      def key_of(*args, &block)
        @reference_table.key_of(*args, &block)
      end
    end
  end
end
