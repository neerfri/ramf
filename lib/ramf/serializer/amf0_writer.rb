module RAMF
  module Serializer
    class AMF0Writer
      include RAMF::IO::Constants
      include RAMF::IO::CommonReadWrite
      include RAMF::IO::ReferenceTableUser
      
      def initialize(reference_table = nil)
        register_reference_table(reference_table)
        @U29_integer_mappings = {}
        @U32_double_mappings = {}
      end
      
      def write(object,stream)
        case
          when object.nil?
        end    
      end
    end
  end
end