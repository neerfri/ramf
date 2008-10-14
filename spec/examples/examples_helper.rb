module ExampleHelper
  
  class OperationProcessor
    def self.will_process?(operation)
      true
    end
    
    def self.process(operation)
      #this is used to check the existence of credentials
      credentials = operation.credentials[:userid] ? "with credentials #{operation.credentials.inspect}" : "without credentials"
      if operation.login?
        #check handling of login operation requests
        "Logging in " << credentials
      elsif operation.remoting_message?
        #check handling of remoting messages
        "RemotingMessage: #{operation.service}.#{operation.method} " << credentials
      else
        #check handling of simpele amf (non messaging)
        "SimpleAMF: #{operation.service}.#{operation.method} " << credentials
      end
    end
  end
  
  def incoming_amf_object_examples(options = {})
    options = {:headers=>0, :messages=>1}.merge(options)
    it('should be_an_instance_of(AMFObject)') {@incoming_amf_object.should be_an_instance_of(AMFObject)}
    it('should have ' + options[:headers].to_s + ' headers') {@incoming_amf_object.headers.size.should == options[:headers]}
    it('should have ' + options[:messages].to_s + ' message') { @incoming_amf_object.messages.size.should == options[:messages] }
    it('should declare amf version 0') { @incoming_amf_object.version.should == 0 }
    it('should declare client 3') { @incoming_amf_object.client.should == 3 }
  end
  
  def incoming_amf_object_message_examples(options = {})
    it('should be an instance of AMFMessage') { @message.should be_an_instance_of(AMFMessage) }
    it('should declare amf version 3') { @message.amf_version.should == 3 }
    it('should declare response uri ' + options[:response_uri].inspect) { @message.response_uri.should == options[:response_uri] }
    it('should declare length '+ options[:length].inspect) { @message.length.should == options[:length] }
    it('should declare target_uri ' + options[:target_uri].inspect) { @message.target_uri.should == options[:target_uri] }
  end
  
  def incoming_amf_object_message_value_examples(options = {})
    it('should be an instance of '+options[:class].name) { @value.should be_an_instance_of(options[:class]) }
    it('should declare timestamp 0') { @value.timestamp.should == 0 }
    it('should declare headers '+options[:headers].inspect){ @value.headers.should == options[:headers] }
    it('should declare clientId nil') { @value.clientId.should == nil }
    it('should declare timeToLive 0') { @value.timeToLive.should == 0 }
    it('should declare messageId ' + options[:messageId].inspect) { @value.messageId.should == options[:messageId] }
    it('should declare body '+options[:body].inspect) { @value.body.should == options[:body] }
    it('should declare destination '+options[:destination].inspect) { @value.destination.should == options[:destination] }
    it('should declare operation '+options[:operation].inspect) { @value.operation.should == options[:operation] }
  end
  
  def processed_incoming_amf_object_examples(options = {})
    it('should be an instance of AMFObject') {@processed_incoming_amf_object.should be_an_instance_of(AMFObject)}
    it('should declare version 0') {@processed_incoming_amf_object.version.should == 0}
    it('should declare client 3') {@processed_incoming_amf_object.client.should == 3}
    it('should declare headers []') {@processed_incoming_amf_object.headers.should == []}
    it('should have 1 message') {@processed_incoming_amf_object.messages.size.should == 1}
  end
  
  def processed_incoming_amf_object_message_examples(options = {})
    it('should be an instance of AMFMessage') {@message.should be_an_instance_of(AMFMessage)}
    it('should declare amf_version 3') {@message.amf_version.should == 3}
    it('should declare length -1') {@message.length.should == -1}
    it('should declare response_uri ""') {@message.response_uri.should == ""}
    it('should declare target_uri '+options[:target_uri].inspect) {@message.target_uri.should == options[:target_uri]}
  end
  
  def processed_incoming_amf_object_message_value_examples(options = {})
    it('should be an instance of FlexObjects::AcknowledgeMessage') {@value.should be_an_instance_of(FlexObjects::AcknowledgeMessage)}
    it('should declare body '+options[:body].inspect) {@value.body.should == options[:body] }
    it('should declare correlationId '+options[:correlationId].inspect) {@value.correlationId.should == options[:correlationId] }
    it('should declare messageId in the right form') {@value.messageId.should =~ /^.{8}-.{4}-.{4}-.{4}-.{12}$/ }
  end
end