module RAMF
  module IO
    module CommonReadWrite
      BigEndian = :BigEndian
      LittleEndian = :LittleEndian
      @@BYTE_ORDER = nil
      
      #examines the locale byte order on the running machine
      def byte_order
        if @@BYTE_ORDER.nil?
          @@BYTE_ORDER = ([0x12345678].pack("L") == "\x12\x34\x56\x78") ? :BigEndian : :LittleEndian  
        end
      end
    
      def byte_order_little?
        (byte_order == :LittleEndian)
      end
    
      def byte_order_big?
        (byte_order == :BigEndian)
      end
      
      def readU8(stream)
        stream.read(1).unpack('C').first
      end
      
      def readU16(stream)
        stream.read(2).unpack('n').first
      end
      
      def readU32(stream)
        stream.read(4).unpack('N').first
      end
      
      def read_double(stream)
        stream.read(8).unpack('G').first
      end
      
      def readUTF8(stream)
        length = readU16(stream)
        stream.read(length)
      end
      
      def writeU16(val,stream)
        str = [val].pack('n')
        stream << str
      end
      
      #write an unsigned 32-bit integer in network (big-endian) byte order
      def writeU32(val,stream)
        stream << [val].pack('N')
      end
      
      def writeUTF8(string,stream)
        writeU16(string.length,stream) 
        stream << string
      end
      
      def write_double(val,stream)
        stream << ( @U32_double_mappings[val] ||= [val].pack('G'))
      end
      
    end
  end
end