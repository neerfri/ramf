module RAMF
  module Deserializer
    class AMF3Reader
      include RAMF::IO::Constants
      include RAMF::IO::CommonReadWrite
      include RAMF::IO::ReferenceTableUser
      
      def initialize(reference_table = nil)
        register_reference_table(reference_table)
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

      private
      #reads an integer encoded as U29
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
        (str = stream.read(length)) == "" ? str : store(:string){str}
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
          readU29O_ref(member_count_or_ref>>1) #The object is a reference
        elsif (member_count_or_ref & 0x02) == 0
          readU29O_traits_ref(stream, member_count_or_ref>>2) #the class is a reference, the object is new.
        elsif (member_count_or_ref & 0x04) == 0x04
          raise "can't read IExternalizable yet"
        elsif (member_count_or_ref & 0x08) == 0
          #new object of a non dynamic class 
          readU29O_traits(stream, member_count_or_ref>>4, false)
        else
          #new object of a dynamic class 
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
          obj.class.flex_remoting.dynamic_members_writer.call(obj, member_name, read_value_type(stream))
          member_name = readUTF_8_vr(stream)
        end
        obj
      end
      
      
      def readU29O_traits(stream, member_count,is_dynamic)
        class_signature = store :class do
          RAMF::IO::FlexClassSignature.new(readUTF_8_vr(stream), is_dynamic, read_object_member_names(stream,member_count))
        end
#        RAMF::DEBUG_LOG.debug "Created new class signature: #{class_signature.inspect}"
        readU29O_object_values(stream,class_signature)
      end
      
      def readU29O_object_values(stream,class_signature)
        store :object do
          object = load_or_create_object(class_signature)
          read_object_member_values(stream,class_signature,object)
          read_object_dynamic_members(stream, object) if class_signature.is_dynamic
          object
        end
      end
      
      def load_or_create_object(class_signature)
        load_or_create_class(class_signature).new
      end
      
      def load_or_create_class(class_signature)
        class_name = class_signature.name.to_s.split(".").each{|s| s[0,1]=s[0,1].upcase}.join("::")
        unless class_name=="" || (/\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ class_name)
         raise NameError, "#{class_name.inspect} is not a valid constant name!"
        end
        RAMF::FlexClassTraits.find_ruby_class(class_name) || (Object.module_eval(class_name) rescue create_class(class_signature))
      end
      
      def create_class(class_signature)
        class_name = class_signature.name.to_s.split(".").each{|s| s[0,1]=s[0,1].upcase!}.join("::")
        Object.module_eval("class #{class_name};end;", __FILE__, __LINE__)
        klass = Object.module_eval(class_name, __FILE__, __LINE__)
        klass.class_eval do
          class_signature.members.each {|m| attr_accessor m}
        end
#        puts "Created new class:#{klass} with members:#{class_signature.members.join(',')}"
        klass
      end
      
      def read_object_member_names(stream,member_count)
        members = []
        member_count.times do
          members << readUTF_8_vr(stream)
        end
        members
      end
      
      def read_object_member_values(stream,flex_class,obj)
        flex_class.members.each do|key|
          value = read_value_type(stream)
          obj.class.flex_remoting.members_writer.call(obj, key, value)
        end
        obj
      end
      
      def readU29X(stream)
        length_or_ref = readU29(stream)
        #check if the XML is a reference or value.
        #XML references are stored in the object reference table. 
        (length_or_ref & 0x01) == 0 ? readU29O_ref(length_or_ref>>1, stream) : readU29X_value(length_or_ref>>1, stream)
      end
      
      def readU29X_value(length, stream)
        store :object do
          defined?(REXML::Document) ? REXML::Document.new(stream.read(length)) : stream.read(length)
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
        RAMF::FlexObjects::ByteArray.new(stream.read(length))
      end
      
      def readUTF_8_vr(stream)
        readU29S(stream)
      end
      
    
    end
  end
end