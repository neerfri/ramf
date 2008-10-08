class RAMF::FlexObjects::RemotingMessage
  flex_alias 'flex.messaging.messages.RemotingMessage'
  flex_remoting_members :operation, :source, :correlationId, :clientId, 
                        :messageId, :body, :timestamp, :timeToLive, 
                        :destination, :headers
                        
  attr_accessor :operation, :source, :correlationId, :clientId, 
                :messageId, :body, :timestamp, :timeToLive, 
                :destination, :headers
                
  
  #construct an Operation object from the remoting message <tt>message</tt>
  def to_operation
    RAMF::OperationRequest.new :service => RAMF::Util.service_name(source),
                               :method => RAMF::Util.method_name(operation),
                               :args => body
                               :messageId=>messageId
  end
  
end