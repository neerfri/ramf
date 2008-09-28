module RAMF
  module Serializer
    class AMF0Writer
      include RAMF::IO::Constants
      include RAMF::IO::CommonReadWrite
      include RAMF::IO::ReferenceTableUser
      
      def initialize(scope, reference_table = nil)
        register_reference_table(reference_table)
        @U29_integer_mappings = {}
        @double_mappings = {}
        @scope = scope
      end
      
      def write_value_type(object,stream)
        case
          when (index = retrive(:object, object))
            stream.write AMF0_REFERENCE_MARKER
            writeU16(index)
          when object.nil?
            stream.write AMF0_NULL_MARKER
          when object.is_a?(Numeric)
            stream.write AMF0_NUMBER_MARKER
            write_double(object,stream)
          when object.is_a?(String) || object.is_a?(Symbol)
            if object.to_s.length <= 65535
              stream.write AMF0_STRING_MARKER
              writeUTF8(object, stream)
            else
              stream.write AMF0_LONG_STRING_MARKER
              writeUTF8Long(object, stream)
            end
          when object.is_a?(TrueClass) || object.is_a?(FalseClass)
            stream.write AMF0_BOOLEAN_MARKER
            writeU8(object ? 1:0, stream)
          when object.is_a?(Array)
            stream.write AMF0_ARRAY_MARKER
            write_strict_array(object, stream)
          when object.is_a?(Hash)
            stream.write AMF0_ECMA_ARRAY_MARKER 
            write_ecma_array(object, stream)
          when object.is_a?(Date) || object.is_a?(Time)
            stream.write AMF0_DATE_MARKER
            write_date(object, stream)
          when object.class.name == "REXML::Document"
            stream.write AMF0_XML_MARKER
            write_xml(object, stream)
          when object.is_a?(RAMF::FlexObjects::FlexAnonymousObject)
            stream.write AMF0_OBJECT_MARKER
            write_anonymous_object(object, stream)
        end
      end
      
      def write_strict_array(array, stream)
        writeU32(array.size, stream)
        array.each {|v| write_value_type(v, stream)}
      end
      
      def write_ecma_array(hash, stream)
        writeU32(hash.size, stream)
        write_object_properties(hash, stream)
      end
      
      def write_date(date, stream)
        secs = date.is_a?(Time) ? date.utc.to_i : date.strftime("%s").to_i
        write_double(secs.to_i * 1000,stream)
        steram.write "\000\000" #reserved for timezone serialization, not used.
      end
    
      def write_xml(xml, stream)
        writeUTF8Long(xml.to_s, stream)
      end
      
      def write_anonymous_object(object, stream)
        properties_hash = {}
        object.class.flex_remoting.members(@scope).each {|member| properties_hash[member] = object.send(member)}
        object.flex_dynamic_members.each {|member, value|properties_hash[member] = value }
        write_object_properties(properties_hash, stream)
      end
      
      def write_object_properties(properties_hash, stream)
        properties_hash.each {|k,v| writeUTF8(k.to_s); write_value_type(v)}
        writeUTF8("")
        stream.write AMF0_OBJECT_END_MARKER
      end
    
    end      
  end
end