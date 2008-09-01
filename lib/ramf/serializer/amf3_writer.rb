require 'date'

module RAMF
  module Serializer
    class AMF3Writer
      include RAMF::IO::Constants
      include RAMF::IO::CommonReadWrite
      include RAMF::IO::ReferenceTableUser
      
      def initialize(reference_table = nil)
        register_reference_table(reference_table)
        @U29_integer_mappings = {}
        @double_mappings = {}
      end
      
      
      def write_value_type(object,stream)
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
                writeU29(object,stream)
              else
                stream << AMF3_DOUBLE_MARKER
                write_double(object.to_f,stream)
              end
          when object.is_a?(String) || object.is_a?(Symbol)
            stream << AMF3_STRING_MARKER
            write_utf8_vr(object.to_s,stream)
          when object.is_a?(Array)
            stream << AMF3_ARRAY_MARKER
            write_array_type(object, stream)
          when object.is_a?(Date) || object.is_a?(Time)
            stream << AMF3_DATE_MARKER
            writeU29D(object, stream)
          when object.class.name == "REXML::Document"
            stream << AMF3_XML_STRING_MARKER
            writeU29X(object, stream)
          when object.is_a?(::IO)
            #TODO: write ByteArray type
          else
            RAMF::DEBUG_LOG.debug "Writing object #{object.inspect}, position in stream: #{stream.pos}"
            stream << AMF3_OBJECT_MARKER
            writeU29O(object,stream)
        end
      end
      
      private
      
      #writes an integer encoded as U29
      def writeU29(int,stream)
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
      
      def write_utf8_vr(str,stream)
        writeU29(0x01,stream) && return if str == ""
        if (index = retrive(:string, str))
          puts "#{str} is coded by reference at #{stream.pos}"
          writeU29(index << 1, stream)
        else
          store :string, str
          writeU29((str.length << 1) | 1, stream)
          stream << str
        end
      end
      
      def write_array_type(array, stream)
        if (index = retrive(:object, array))
          writeU29(index << 1, stream)
        else
          store :object, array
          writeU29A_value(array, stream)
        end
      end
      
      def writeU29A_value(array, stream)
        writeU29((array.length << 1) | 1, stream)
        stream << AMF3_EMPTY_STRING #ruby's array is always a strict array
        array.each{|item| write_value_type(item, stream) }
      end
            
      def writeU29O(object, stream)
        if (index = retrive(:object, object))
          #Object has already been writen, write the reference number.
          writeU29(index << 1, stream)
        else
          if (index = retrive(:class, object.class))
            #Class has already been writen, write the reference number.
            writeU29((index << 2) | 0x01,stream)
          else
            #We need to write the class traits
            RAMF::DEBUG_LOG.debug "Writing class traits for #{object.class}"
            store :class, object.class
            writeU29O_object_traits(object,stream)
          end
          #Now write the object
          RAMF::DEBUG_LOG.debug "Writing object attributes #{object.inspect}"
          store :object, object
          #write sealed members
          writeU29O_object_members(object, stream)
          #write dynamic members
          if object.class.flex_remoting.is_dynamic && object.respond_to?(:flex_dynamic_members)
            writeU29O_object_dynamic_members(object, stream) 
          end
        end
      end
      
      
      def  writeU29O_object_members(object,stream)
        RAMF::DEBUG_LOG.debug "Writing sealed members for #{object.inspect}"
        object.class.flex_remoting.members.each do |member|
          RAMF::DEBUG_LOG.debug "Writing sealed member #{member}"
          write_value_type(object.send(member), stream)
        end
      end
      
      def writeU29O_object_dynamic_members(object, stream)
        RAMF::DEBUG_LOG.debug "Writing dynamic members for #{object.inspect}"
        object.flex_dynamic_members.each do |member_name, member_value|
          RAMF::DEBUG_LOG.debug "Writing dynamic member #{member_name}"
          write_utf8_vr(member_name.to_s, stream)
          write_value_type(member_value, stream)
        end
        write_utf8_vr("", stream)
      end
      
      def writeU29O_object_traits(object,stream)
        flex_remoting = object.class.flex_remoting
        member_count = flex_remoting.members.size
        mask = flex_remoting.is_dynamic ? 0x0B : 0x03
        RAMF::DEBUG_LOG.debug "Writing traits marker member count:#{member_count}, mask:#{mask.to_s(2)}"
        writeU29((member_count << 4) | mask, stream)
        RAMF::DEBUG_LOG.debug "Writing traits name: #{flex_remoting.name.inspect}"
        write_utf8_vr(flex_remoting.name, stream) #Write class name
        flex_remoting.members.each {|m| write_utf8_vr(m, stream)} #Write class's sealed members
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
        stream << xml.to_s
      end
      
    end
  end
end