module RAMF
  module Deserializer
    class Base
      include RAMF::IO::CommonReadWrite
      include RAMF::IO::ReferenceTableUser
      
      def initialize(stream)
        @stream = stream
        @amf_object = RAMF::AMFObject.new
      end
      
      def process
        read_preamble
        read_headers
        read_messages
        @amf_object
      end
      
      def read_preamble
        version = readU8(@stream)
        if version != 0 && version != 3
          #TODO: replace this with a proper error object
          raise  "The amf version is incorrect"
        end
        
        client = readU8(@stream)
        @amf_object.version, @amf_object.client = version, client
      end
      
      def read_headers
        header_count = readU16(@stream)
        header_count.times do
          @amf_object.add_header(read_header)
        end
      end
      
      def read_header
        register_reference_table
        #Read header's name
        name = readUTF8(@stream)
        #Read the 'must-understand' flag
        must_understand = readU8(@stream)
        #Read the header's length
        length = readU32(@stream)
        
        #Read header's value
        value = AMF0Reader.new.read_value_type(@stream)
        AMFHeader.new(name,value,must_understand)
      end
      
      def read_messages
        message_count = readU16(@stream)
        message_count.times do
          @amf_object.add_message(read_message)
        end
      end
      
      def read_message
        
        #Read message's target_uri
        target_uri = readUTF8(@stream)
        #Read message's response_uri
        response_uri = readUTF8(@stream)
        #Read the message's length
        length = readU32(@stream)
        
        #Read message's value
        value = AMF0Reader.new.read_value_type(@stream)
        AMFMessage.new :target_uri=> target_uri,
                       :response_uri=> response_uri,
                       :value=> value
      end
          
    end
  end
end
    