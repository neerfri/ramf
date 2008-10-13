#Represents an opration request comming from AMF
#the opration could come in through messaging or simple amf protocol
class RAMF::OperationRequest
  attr_accessor :service, :method, :args, :operation, :credentials, :messageId
  
  def initialize(options)
    [:service, :method, :args, :operation, :credentials, :messageId].each do |att|
      self.instance_variable_set("@#{att}",options[att])
    end
  end
  
  #is the operation a ping operation
  def ping?
    operation == RAMF::FlexObjects::CommandMessage::CLIENT_PING_OPERATION
  end
  
  def messaging?
    !messageId.nil?
  end
  
  def remoting_message?
    messaging? && !operation
  end
  
  def login?
    operation == RAMF::FlexObjects::CommandMessage::LOGIN_OPERATION
  end
  
  #generate a response for that operation request
  def response(value = nil)
    if messaging?
      if ping?
        RAMF::FlexObjects::AcknowledgeMessage.new :correlationId=>messageId
      else
        RAMF::FlexObjects::AcknowledgeMessage.new :correlationId=>messageId, :body=>value
      end
    else
      #Non messaging
      value
    end
  end
  
  def exception_response(exception)
    if messaging?
      RAMF::FlexObjects::ErrorMessage.new :correlationId=>messageId, :exception=>exception
    else
      exception
    end
  end
  
end