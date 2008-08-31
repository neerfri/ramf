module RAMF
  class AMFMessage
    attr_accessor :target_uri, :response_uri, :value, :length
    
    def initialize(options)
      @target_uri = options[:target_uri]
      @response_uri = options[:response_uri]
      @value = options[:value]
      @length = options[:length] || -1
    end
    
  end
end