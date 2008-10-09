class RAMF::FlexObjects::RemotingMessage
  flex_alias 'flex.messaging.messages.RemotingMessage'
  flex_remoting_members :operation, :source, :correlationId, :clientId, 
                        :messageId, :body, :timestamp, :timeToLive, 
                        :destination, :headers
                        
  attr_accessor :operation, :source, :correlationId, :clientId, 
                :messageId, :body, :timestamp, :timeToLive, 
                :destination, :headers
                
  def credentials_header
    RAMF::Util.extract_credentials(headers[:DSRemoteCredentials].to_s) || {:userid => nil, :password => nil}
  end
  
  #construct an Operation object from the remoting message <tt>message</tt>
  def to_operation
    RAMF::OperationRequest.new :service => RAMF::Util.service_name(destination.to_s),
                               :method => RAMF::Util.method_name(operation.to_s),
                               :args => body,
                               :credentials => credentials_header,
                               :messageId=>messageId
  end
  
end