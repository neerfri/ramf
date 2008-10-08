module RAMF
  class AMFMessage
    attr_accessor :target_uri, :response_uri, :value, :length, :amf_version
    
    def initialize(options)
      @target_uri = options[:target_uri]
      @response_uri = options[:response_uri]
      @value = options[:value]
      @length = options[:length] || -1
      @amf_version = options[:amf_version] || 3
    end
    
    def to_operation
      case @value.first.class.name
        when  "RAMF::FlexObjects::CommandMessage"
          RAMF::FlexObjects::CommandMessage.parse(@value.first)
        when "RAMF::FlexObjects::RemotingMessage"
          raise "Remoting message not yet implemented..."
      else
        RAMF::OperationRequest.new :method=>method_name(target_uri),
                                   :service=>service_name(target_uri),
                                   :args=>Array(value)
      end
    end
    
    private
    def method_name(target_uri)
      RAMF::Util.underscore(target_uri[target_uri.rindex(".")+1..-1])
    end
    
    def service_name(uri)
      uri[0..uri.rindex(".")].split(".").each{|s| s[0..0] = s[0..0].upcase}.join("::")
    end
    
  end
end