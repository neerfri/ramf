module RAMF
  module Deserializer
    class AMF0Reader
      include RAMF::Constants
      include RAMF::CommonReadWrite
      include RAMF::ReferenceTableUser
      
      def initialize(reference_table = nil)
        register_reference_table(reference_table)
      end
      
      def read_value_type(stream)
        marker = readU8(stream)
        case marker
          when AMF3_TYPE
            AMF3Reader.new(@reference_table).read_value_type(stream)
          when AMF0_NUMBER
            read_double(stream)
          when AMF0_BOOLEAN
            (readU8(stream) == 0) ? false : true
          when AMF0_STRING
            readUTF8(stream)
          when AMF0_OBJECT
            #TODO: implement this
            readObject(stream)
          when AMF0_ARRAY
            read_strict_array(stream)
          else
            raise "unknown amf0 value marker 0x%02X" % marker
        end
      end
      
      
      
      def read_strict_array(stream)
        array_length = readU32(stream)
        array = []
        array_length.times do
          array << read_value_type(stream)
        end
        array
      end
      
      def readObject(stream)
        obj = Object.new
        member_name = readUTF8(stream)
        while (member_name != "") do #run until we get to the empty-string marker
          obj.eval do
            class << self
              attr_accessor member_name.to_sym
            end
            self.send(member_name+"=",readUTF_8_vr(stream))
          end
        end
      end
    
    
    end
  end
end
    