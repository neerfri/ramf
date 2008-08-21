module RAMF
  module Serializer
    class Base
      include CommonReadWrite
      include Constants
      
      def initialize(amf_version)
        @stream = StringIO.new
        @amf_version = amf_version
      end
      
      def write(object)
        #write the amf version
        writeU16(0,@stream)
        writeU16(object.headers.length,@stream)
#        puts object.inspect
        object.headers.each do |header|
          #write the header name
          writeUTF8(header.name,@stream)
          #write the must-understand byte
          header.must_understand ? writeU8(0x01,@stream) : writeU8(0x00,@stream)
          #unknow header size so:
          writeU32(-1,@stream)
          #write the header data
          AMF0Writer.new().write(header.value,@stream)
        end
        
        writeU16(object.messages.length,@stream)
        object.messages.each do |message|
          writeUTF8(message.target_uri,@stream)
          writeUTF8("null",@stream)
          #unknow message size so:
          writeU32(-1,@stream)
          if @amf_version == 3
            @stream << AMF3_TYPE_MARKER
            AMF3Writer.new.write(message.value,@stream)
          elsif @amf_version == 0
            AMF0Writer.new.write(message.value,@stream)
          end
        end
        
        @stream.rewind
        @stream.read
      end
    end
  end
end