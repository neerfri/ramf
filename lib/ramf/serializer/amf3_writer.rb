module RAMF
  module Serializer
    class AMF3Writer
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
            stream << AMF3_NULL_MARKER
          when object.is_a?(FalseClass)
            stream << AMF3_FALSE_MARKER
          when object.is_a?(TrueClass)
            stream << AMF3_TRUE_MARKER
          when object.is_a?(Numeric)
              if (object.is_a?(Fixnum) && object >= AMF3_INTEGER_MIN && object <= AMF3_INTEGER_MAX) #check valid range for 29bits
                stream << AMF3_INTEGER_MARKER
                write_integer(object,stream)
              else
                stream << AMF3_DOUBLE_MARKER
                write_double(object.to_f,stream)
              end
          when object.is_a?(String)
            stream << AMF3_STRING_MARKER
            write_utf8_vr(object,stream)
          when object.is_a?(Array)
            stream << AMF3_ARRAY_MARKER
            write_array(object, stream)
          else
            stream << AMF3_OBJECT_MARKER
            write_object(object,stream)
        end
      end
      
      def write_integer(int,stream)
        stream << (@U29_integer_mappings[int] ||= calculate_integer_U29(int))
      end
      
      def calculate_integer_U29(int)
        int = int & 0x1fffffff
        case
          when int < 0x80
            [int].pack('c')
          when int < 0x4000
            [int >> 7 & 0x7f | 0x80].pack('c')+
              [int & 0x7f].pack('c')
          when int < 0x200000
            [int >> 14 & 0x7f | 0x80].pack('c')+
              [int >> 7 & 0x7f | 0x80].pack('c')+
              [int & 0x7f].pack('c')
          else
            [int >> 22 & 0x7f | 0x80].pack('c')+
              [int >> 15 & 0x7f | 0x80].pack('c')+
              [int >> 8 & 0x7f | 0x80].pack('c')+
              [int & 0xff].pack('c')
        end
      end
      
      def write_double(num,stream)
        stream << ( @U32_double_mappings[num] ||= [num].pack('G'))
      end
      
      def write_utf8_vr(str,stream)
        stream << 0x01 && return if str == ""
        if (index = retrive(:string, str))
          puts "#{str} is coded by reference at #{stream.pos}"
          write_integer(index << 1, stream)
        else
          store :string, str
          write_integer((str.length << 1) | 1, stream)
          stream << str
        end
      end
      
      def write_array(array, stream)
        if (index = retrive(:object, array))
          write_integer(index << 1, stream)
        else
          store :object, array
          write_integer((array.length << 1) | 1, stream)
          stream << AMF3_EMPTY_STRING #ruby's array is always a strict array
          array.each{|item| write(item, stream) }
        end
      end
      
      def write_non_dynamic_object(object,stream)
        #TODO: implement a settings mechanism for classes, and then implement this:
        if (traits_ref = retrive(:class, klass))
          write_integer((index << 2) | 1, stream)
        else
          definition = klass.remoting_copy
          number_of_sealed_members = definition[:members].count
          write_integer((number_of_sealed_members << 4) | 0x03) #03 implies non-referenced, non-dynamic trait 
        end
      end
      
      def write_dynamic_object(object,stream)
        write_integer(object.class.flex_reflection.members.length << 4 | 0xb, stream)
        write_utf8_vr(object.class.flex_reflection.name.to_s,stream)
        object.class.flex_reflection.members.each {|name| write_utf8_vr(name,stream)}
        object.class.flex_reflection.members.each {|name| write(object.send(name),stream)}
        object.flex_dynamic_members.each do |member_name, member_value|
          write_utf8_vr(member_name,stream)
          write(member_value,stream)
        end
        stream << AMF3_EMPTY_STRING
      end
      
      def write_object(object, stream)
        if (index = retrive(:object, object))
          write_integer(index << 1, stream)
        else
          object.class.flex_reflection.is_dynamic ? 
            write_dynamic_object(object,stream) : write_non_dynamic_object(object,stream)
        end
      end
    end
  end
end