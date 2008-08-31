module RAMF
  class AMFObject
    
    AMF0_VERSION = 0x00
    AMF3_VERSION = 0x03
    
    FP_CLIENT = 0x01 #for Flash Player 8
    FLASH_COM = 0x01 #for FlashCom/FMS
    FP9_CLIENT =0x03 #for Flash Player 9

    attr_accessor :version, :client, :headers, :messages
    
    def initialize(options={})
      @version     = options[:version] || AMF3_VERSION
      @client   = options[:client] || FP9_CLIENT
      @headers  = options[:headers] || []
      @messages = options[:messages] || []
    end
    
    def add_header(header)
      @headers << header
    end
    
    def add_message(message)
      @messages << message
    end
    
    def get_header_by_key(key)
      @headers.find {|v| v.name == key.to_s}
    end
    
  end
end