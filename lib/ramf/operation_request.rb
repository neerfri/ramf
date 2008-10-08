#Represents an opration request comming from AMF
#the opration could come in through messaging or simple amf protocol
class RAMF::OperationRequest
  attr_accessor :service, :method, :args, :operation, :messageId
  
  def initialize(options)
    [:service, :method, :args, :operation].each do |att|
      self.instance_variable_set("@#{att}",options[att])
    end
  end
  
  #is the operation a ping operation
  def ping?
    operation == RAMF::FlexObjects::CommandMessage::CLIENT_PING_OPERATION
  end
  
  #generate a response for that operation request
  #at the moment only works for ping operations
  def response(value)
    if ping?
      RAMF::FlexObjects::AcknowledgeMessage.new :correlationId=>messageId
    else
      RAMF::FlexObjects::AcknowledgeMessage.new :correlationId=>messageId, :body=>value
    end
  end
  
end