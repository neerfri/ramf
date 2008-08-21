module RAMF
  class RailsGateway
    
    def process(request,response)
      @request, @response = request, response
      @request_amf = StringIO.open(request.raw_post,'r') {|s| Deserializer::Base.new(s).process}
      @response_amf = AMFObject.new :version=>@request_amf.version,
                                    :client=>@request_amf.client
      @request_amf.messages.each {|message| process_message(message)}
      response = StringIO.open {|s| Serializer::Base.new(3).write(@response_amf)}
      File.open("/home/neer/workspace/RAMF/response.out","w+") {|f| f << response}
      response
    end
    
    def process_message(message)
      service, action = message.target_uri.split(".") 
      controller = service.gsub("Controller","").underscore
      request = @request.clone
      response = @response.clone
      request.parameters.merge!({:controller=>controller, :action=>action})
      service = service.constantize.new
      service.request_amf = @request_amf
      service.process(request,response)
      message = AMFMessage.new :target_uri=>message.response_uri + '/onResult',
                               :response_uri=>"",
                               :value=>service.render_amf
      @response_amf.add_message(message)
    end
  end
end