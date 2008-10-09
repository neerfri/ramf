module RAMF
  class AMFMessage
    attr_accessor :target_uri, :response_uri, :value, :length, :amf_version
    KNOWN_MESSAGE_OBJECTS = ["RAMF::FlexObjects::CommandMessage","RAMF::FlexObjects::RemotingMessage"]
    
    def initialize(options)
      @target_uri = options[:target_uri]
      @response_uri = options[:response_uri]
      @value = options[:value]
      @length = options[:length] || -1
      @amf_version = options[:amf_version] || 3
    end
    
    def to_operation(options = {})
      if KNOWN_MESSAGE_OBJECTS.include?(@value.first.class.name)
        @value.first.to_operation
      else
        RAMF::OperationRequest.new :method=>RAMF::Util.method_name(target_uri),
                                   :service=>RAMF::Util.service_name(target_uri),
                                   :args=>Array(value),
                                   :credentials=>options[:credentials]
      end
    end
    
  end
end