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
    
    def credentials_header
      (header = get_header_by_key("Credentials")) ? header.value : {:userid => nil, :password => nil}
    end
    
    def process(*processor_args)
      returning(RAMF::AMFObject.new(:version=>version)) do |response|
        response.messages = messages.map do |incoming_message|
          operation = incoming_message.to_operation(:credentials=>credentials_header)
          begin
            RAMF::AMFMessage.new :target_uri=>incoming_message.response_uri + "/onResult",
                                 :response_uri=>"",
                                 :value=>RAMF::OperationProcessorsManager.process(operation, *processor_args)
          rescue RAMF::OperationProcessorsManager::ErrorWhileProcessing => e
            RAMF::AMFMessage.new :target_uri=>incoming_message.response_uri + "/onStatus",
                                 :response_uri=>"",
                                 :value=> operation.exception_response(e.original_exception)
          end
        end
      end
    end
    
  end
end