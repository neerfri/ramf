module RAMF
  module IO
    #this class is used to save the signature of a class during (de)serializtion process.
    #it cann't be changed after creation cause that will damage the (de)serialization process.
    class FlexClassSignature
      
      attr_reader :name, :is_dynamic, :members
      
      def initialize(name,is_dynamic,members)
        @name = name.empty? ? name : name.to_sym
        @is_dynamic = is_dynamic
        @members = members
      end
    end
  end
end
