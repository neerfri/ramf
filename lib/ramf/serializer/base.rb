module RAMF
  module Serializer
    class Base
      include RAMF::IO::CommonReadWrite
      include RAMF::IO::Constants
      
      def initialize
        @stream = StringIO.new
      end
      
      def write(object, scope = RAMF::Configuration::DEFAULT_SCOPE)
        #write the amf version
        writeU16(object.version,@stream)
        
        #headers:
        writeU16(object.headers.length,@stream)
        object.headers.each do |header|
          write_header(header, scope)
        end
        
        #messages:
        writeU16(object.messages.length,@stream)
        object.messages.each do |message|
          write_message(message, scope)
        end
        
        @stream.rewind
        @stream.read
      end
      
      private
      def write_header(header, scope)
        #write the header name
        writeUTF8(header.name,@stream)
        #write the must-understand byte
        header.must_understand ? writeU8(0x01,@stream) : writeU8(0x00,@stream)
        #unknow header size so:
        writeU32(-1,@stream)
        #write the header data
        AMF0Writer.new(scope).write_value_type(header.value,@stream)
      end
      
      def write_message(message, scope)
        writeUTF8(message.target_uri,@stream)
        writeUTF8("null",@stream) #we have no response URI
        #unknow message size so:
        writeU32(-1,@stream)
        if message.amf_version == 3
          @stream.write AMF3_TYPE_MARKER
          AMF3Writer.new(scope).write_value_type(message.value,@stream)
        elsif message.amf_version == 0
          AMF0Writer.new(scope).write_value_type(message.value,@stream)
        end
      end
    end
  end
end