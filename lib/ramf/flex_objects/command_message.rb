class RAMF::FlexObjects::CommandMessage
  flex_alias "flex.messaging.messages.CommandMessage"
  flex_remoting_members :operation, :correlationId, :clientId, 
                        :messageId, :body, :timestamp, :timeToLive, 
                        :destination, :headers
                        
  attr_accessor :operation, :correlationId, :clientId, 
                :messageId, :body, :timestamp, :timeToLive, 
                :destination, :headers
                        
  ######################################OPERATION TYPES###############################3
  #holdes the operations names for easier debugging and exception reporting
  OPERATION_NAMES = {}  

  #This operation is used to subscribe to a remote destination.
  SUBSCRIBE_OPERATION = 0; OPERATION_NAMES[0] = "SUBSCRIBE_OPERATION"

  #This operation is used to unsubscribe from a remote destination.
  UNSUBSCRIBE_OPERATION = 1; OPERATION_NAMES[1] = "UNSUBSCRIBE_OPERATION"

  #This operation is used to poll a remote destination for pending, undelivered messages.
  POLL_OPERATION = 2; OPERATION_NAMES[2] = "POLL_OPERATION"

  #This operation is used by a remote destination to sync missed or cached messages 
  #back to a client as a result of a client issued poll command.
  CLIENT_SYNC_OPERATION = 4; OPERATION_NAMES[4] = "CLIENT_SYNC_OPERATION"

  #This operation is used to test connectivity over the current channel to
  #the remote endpoint.
  CLIENT_PING_OPERATION = 5; OPERATION_NAMES[5] = "CLIENT_PING_OPERATION"
  
  #This operation is used to request a list of failover endpoint URIs
  #for the remote destination based on cluster membership.
  CLUSTER_REQUEST_OPERATION = 7; OPERATION_NAMES[7] = "CLUSTER_REQUEST_OPERATION"
  
  #This operation is used to send credentials to the endpoint so that
  #the user can be logged in over the current channel.  
  #The credentials need to be Base64 encoded and stored in the <code>body</code>
  #of the message.
  LOGIN_OPERATION = 8; OPERATION_NAMES[8] = "LOGIN_OPERATION"
    
  #This operation is used to log the user out of the current channel, and 
  #will invalidate the server session if the channel is HTTP based.
  LOGOUT_OPERATION = 9; OPERATION_NAMES[9] = "LOGOUT_OPERATION"

  #This operation is used to indicate that the client's subscription with a
  #remote destination has timed out.
  SUBSCRIPTION_INVALIDATE_OPERATION = 10; OPERATION_NAMES[10] = "SUBSCRIPTION_INVALIDATE_OPERATION"

  #Used by the MultiTopicConsumer to subscribe/unsubscribe for more
  #than one topic in the same message.
  MULTI_SUBSCRIBE_OPERATION = 11; OPERATION_NAMES[11] = "MULTI_SUBSCRIBE_OPERATION"
    
  #This operation is used to indicate that a channel has disconnected.
  DISCONNECT_OPERATION = 12; OPERATION_NAMES[12] = "DISCONNECT_OPERATION"
  
  #This is the default operation for new CommandMessage instances.
  UNKNOWN_OPERATION = 10000; OPERATION_NAMES[10000] = "UNKNOWN_OPERATION"

######################################HEADER VALUES###############################

  #Endpoints can imply what features they support by reporting the
  #latest version of messaging they are capable of during the handshake of
  #the initial ping CommandMessage.
  MESSAGING_VERSION = "DSMessagingVersion"
  
  def credentials_for_login_operation
    RAMF::Util.extract_credentials(body.to_s) || {:userid => nil, :password => nil}
  end
  
  #construct an Operation object from the command message <tt>message</tt>
  def to_operation
    case operation
      when CLIENT_PING_OPERATION
        RAMF::OperationRequest.new :operation => operation, 
                                   :messageId=>messageId
      when LOGIN_OPERATION
        RAMF::OperationRequest.new :operation => operation, 
                                   :credentials => credentials_for_login_operation,
                                   :messageId=>messageId
    else
      raise "Unimplemented Operation: #{operation} - #{OPERATION_NAMES[operation]}"
    end
  end
    
end