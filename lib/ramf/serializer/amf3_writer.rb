require 'date'

module RAMF
  module Serializer
    class AMF3Writer
      include RAMF::IO::Constants
      include RAMF::IO::CommonReadWrite
      include RAMF::IO::ReferenceTableUser
      
      def initialize(scope, reference_table = nil)
        register_reference_table(reference_table)
        @U29_integer_mappings = {}
        @double_mappings = {}
        @scope = scope.to_sym
      end
      
      
      def write_value_type(object,stream)
        case
          when object.is_a?(Numeric)
              if (object.is_a?(Fixnum) && object >= AMF3_INTEGER_MIN && object <= AMF3_INTEGER_MAX) #check valid range for 29bits
                stream.write AMF3_INTEGER_MARKER
                writeU29(object,stream)
              else
                stream.write AMF3_DOUBLE_MARKER
                write_double(object.to_f,stream)
              end
          when object.is_a?(String) || object.is_a?(Symbol)
            stream.write AMF3_STRING_MARKER
            write_utf8_vr(object.to_s,stream)
          when object.nil?
            stream.write AMF3_NULL_MARKER
          when object.is_a?(FalseClass)
            stream.write AMF3_FALSE_MARKER
          when object.is_a?(TrueClass)
            stream.write AMF3_TRUE_MARKER
          when object.is_a?(Date) || object.is_a?(Time)
            stream.write AMF3_DATE_MARKER
            writeU29D(object, stream)
          when object.is_a?(Array)
            stream.write AMF3_ARRAY_MARKER
            write_array_type(object, stream)
          when object.class.name == "REXML::Document"
            stream.write AMF3_XML_STRING_MARKER
            writeU29X(object, stream)
          when object.is_a?(::IO) || object.is_a?(::StringIO)
            stream.write AMF3_BYTE_ARRAY_MARKER
            writeU29B(object, stream)
          else
            stream.write AMF3_OBJECT_MARKER
            writeU29O(object,stream)
        end
      end
      
      private
      
      #writes an integer encoded as U29
      def writeU29(int,stream)
        stream.write(@U29_integer_mappings[int] ||= calculate_integer_U29(int))
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
      
      def write_with_reference_check(group, obj, stream, &block)
        if (index = retrive(group, obj))
          writeU29(index << 1, stream)
        else
          store group, obj
          block.call
        end
      end
      
      def write_utf8_vr(str,stream)
        return(writeU29(0x01,stream)) if str == ""
        write_with_reference_check(:string, str, stream) do
          writeU29((str.length << 1) | 1, stream)
          stream.write str
        end
      end
      
      def write_array_type(array, stream)
        write_with_reference_check(:object, array, stream) do
          writeU29A_value(array, stream)
        end
      end
      
      def writeU29A_value(array, stream)
        writeU29((array.length << 1) | 1, stream)
        stream.write AMF3_EMPTY_STRING #ruby's array is always a strict array
        array.each{|item| write_value_type(item, stream) }
      end
            
      def writeU29O(object, stream)
        write_with_reference_check(:object, object, stream) do
          write_with_reference_check(:class, object.class, stream) do
            #We need to write the class traits
            writeU29O_object_traits(object,stream)
          end
          #Now write the object...
          #write sealed members
          writeU29O_object_members(object, stream)
          #write dynamic members
          if object.class.flex_remoting.is_dynamic
            writeU29O_object_dynamic_members(object, stream) 
          end
        end
      end
      
      
      def  writeU29O_object_members(object,stream)
        object.class.flex_remoting.members(@scope).each do |member|
          write_value_type(object.class.flex_remoting.members_reader.call(object,member), stream)
        end
      end
      
      def writeU29O_object_dynamic_members(object, stream)
        object.class.flex_remoting.dynamic_members(object,@scope).each do |member_name, member_value|
          write_utf8_vr(member_name.to_s, stream)
          write_value_type(member_value, stream)
        end
        write_utf8_vr("", stream)
      end
      
      def writeU29O_object_traits(object,stream)
        flex_remoting = object.class.flex_remoting
        member_count = flex_remoting.members(@scope).size
        mask = flex_remoting.is_dynamic ? 0x0B : 0x03
        writeU29((member_count << 4) | mask, stream)
        write_utf8_vr(flex_remoting.name, stream) #Write class name
        flex_remoting.members(@scope).each {|m| write_utf8_vr(m.to_s, stream)} #Write class's sealed members
      end
      
      def writeU29D(date, stream)
        if (index = retrive(:object, date))
          writeU29(index << 1, stream)
        else
          store :object, date
          writeU29D_value(date, stream)
        end
      end
      
      def writeU29D_value(date, stream)
        writeU29(1,stream)
        secs = date.is_a?(Time) ? date.utc.to_i : date.strftime("%s").to_i
        write_double(secs.to_i * 1000,stream)
      end
      
      def writeU29X(xml, stream)
        if (index = retrive(:object, xml))
          writeU29(index << 1, stream)
        else
          store :object, xml
          writeU29X_value(xml, stream)
        end
      end
      
      def writeU29X_value(xml, stream)
        writeU29((xml.to_s.length << 1) | 1, stream)
        stream.write xml.to_s
      end
      
      def writeU29B(io, stream)
        if (index = retrive(:object, io))
          writeU29(index << 1, stream)
        else
          store :object, io
          writeU29B_value(io, stream)
        end
      end
      
      def writeU29B_value(io, stream)
        writeU29((io.length << 1) | 1, stream)
        io.rewind
        stream.write io.read
      end
      
    end
  end
end