module RAMF
  module Deserializer
    class AMF3Reader
      include RAMF::Constants
      include RAMF::CommonReadWrite
      include RAMF::ReferenceTableUser
      
      def initialize(reference_table = nil)
        register_reference_table(reference_table)
      end
      
      def readU29(stream)
        result = 0
        4.times do |i|
          part = readU8(stream)
          result = readU29_part(part, i==3, result)
          break if (part & 0x080)==0
        end
        result
      end
    
      def readU29_part(part, is_last, rest)
        if is_last
          (rest << 8) | part
        else
          (rest << 7) | (part & 0x7f)
        end
      end
      
      # U29 Strings:
      def readU29S_value(length,stream)
        store :string do
          stream.read(length)
        end
      end
      
      def readU29S_ref(ref,stream)
        #retrive string from reference tables
        retrive :string, ref
      end
      
      def readU29S(stream)
        length_or_ref = readU29(stream)
        #check if the string is a reference or value.
        (length_or_ref & 0x01) == 0 ? readU29S_ref(length_or_ref>>1, stream) : readU29S_value(length_or_ref>>1, stream)
      end
      
      #U29 Objects:
      def readU29O(stream)
        member_count_or_ref = readU29(stream)
        if (member_count_or_ref & 0x01) == 0
          readU29O_ref(member_count_or_ref>>1)
        elsif (member_count_or_ref & 0x02) == 0
          readU29O_traits_ref(stream, member_count_or_ref>>2)
        elsif (member_count_or_ref & 0x04) == 0x04
          raise "can't read IExternalizable yet"
        elsif (member_count_or_ref & 0x08) == 0
          #not a dynamic object
          readU29O_traits(stream, member_count_or_ref>>4, false)
        else
          #a dynamic object
          readU29O_traits(stream, member_count_or_ref>>4, true)
        end
      end
      
      def readU29O_ref(ref_id)
        retrive :object, ref_id
      end
      
      def readU29O_traits_ref(stream,ref_id)
        flex_class = retrive :class, ref_id
        readU29O_object_values(stream,flex_class)
      end
      
      def read_object_dynamic_members(stream, obj)
        member_name = readUTF_8_vr(stream)
        while (member_name != "") do #run until we get to the empty-string marker
          obj[member_name.to_sym] = read_value_type(stream)
          member_name = readUTF_8_vr(stream)
        end
        obj
      end
      
      
      def readU29O_traits(stream, member_count,is_dynamic)
        flex_class = store :class do
          class_name = readUTF_8_vr(stream)
          read_object_member_names(stream,member_count,FlexObjects::FlexClass.new(class_name,is_dynamic))
        end
        readU29O_object_values(stream,flex_class)
      end
      
      def readU29O_object_values(stream,flex_class)
        store :object do
  #       puts "reading#{flex_class.is_dynamic ? ' dynamic' : ''} #{flex_class.name} object"
          #put a stub place-holder for the object reference
          #and save the reference id to replace it later.
          obj =  (flex_class.name == "") ? 
              FlexObjects::FlexAnonymousObject.new : FlexObjects::FlexObject.new(flex_class.name.to_sym)
          read_object_member_values(stream,flex_class,obj)
          read_object_dynamic_members(stream, obj) if flex_class.is_dynamic
          obj
        end
      end
      
      def read_object_member_names(stream,member_count,flex_class)
        member_count.times do
          member_name = readUTF_8_vr(stream)
          flex_class.members << member_name
        end
        flex_class
      end
      
      def read_object_member_values(stream,flex_class,obj)
        flex_class.members.each do|key|
  #        pos = stream.pos
          obj[key] = read_value_type(stream)
  #        puts "reading object_member_value #{key} in byte #{pos}: #{obj[key].inspect}"
        end
        obj
      end
      
      def readU29X(stream)
        ref_or_length = readU29(stream)
        #check if the XML is a reference or value.
        #XML references are stored in the object reference table. 
        (length_or_ref & 0x01) == 0 ? readU29O_ref(length_or_ref>>1, stream) : readU29X_value(length_or_ref>>1, stream)
      end
      
      def readU29X_value(length, stream)
        store :object do
          stream.read(length)
        end
      end
      
      def readU29D(stream)
        is_ref = readU29(stream)
        #check if the Date is a reference or value.
        #Date references are stored in the object reference table. 
        (is_ref & 0x01) == 0 ? readU29O_ref(is_ref>>1) : readU29D_value(stream)
      end
      
      def readU29D_value(stream)
        store :object do
          milisec_value = read_double(stream).to_f
          Time.at(milisec_value/1000)
        end
      end
      
      def readU29A(stream)
        ref_or_length = readU29(stream)
        #check if the Array is a reference or value.
        #Array references are stored in the object reference table. 
        (ref_or_length & 0x01) == 0 ? readU29O_ref(ref_or_length>>1) : readU29A_value(ref_or_length>>1, stream)
      end
      
      def readU29A_value(dense_member_count, stream)
        store :object do
          obj = {}
          read_object_dynamic_members(stream, obj)
          obj = [] if obj.empty?
          dense_member_count.times {|i| obj[i] = read_value_type(stream)}
          obj
        end
      end
      
      def readU29B(stream)
        ref_or_length = readU29(stream)
        #check if the ByteArray is a reference or value.
        #ByteArray references are stored in the object reference table. 
        (ref_or_length & 0x01) == 0 ? readU29O_ref(ref_or_length>>1) : readU29B_value(ref_or_length>>1, stream)
      end
      
      def readU29B_value(length,stream)
        StringIO.new(stream.read(length))
      end
      
      def readUTF_8_vr(stream)
        readU29S(stream)
      end
      
      def read_value_type(stream)
        marker = readU8(stream)
        case marker
        when AMF3_UNDEFINED
          nil
        when AMF3_NULL
          nil
        when AMF3_FALSE
          false
        when AMF3_TRUE
          true
        when AMF3_INTEGER
          readU29(stream)
        when AMF3_DOUBLE
          read_double(stream)
        when AMF3_STRING
          readUTF_8_vr(stream)
        when AMF3_XML_DOC
          readU29X(stream)
        when AMF3_XML
          readU29X(stream)
        when AMF3_DATE
          readU29D(stream)
        when AMF3_ARRAY
          readU29A(stream)
        when AMF3_OBJECT
          readU29O(stream)
        when AMF3_BYTE_ARRAY
          readU29B(stream)
        else
          raise "unknown amf3 value marker 0x%02X" % marker
        end
      end
    
    
    end
  end
end