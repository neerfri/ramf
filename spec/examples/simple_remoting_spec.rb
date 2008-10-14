require File.join(File.dirname(__FILE__),'../spec_helper')
include RAMF

describe "RAMF" do
  
  describe "simple_remoting_example" do
    before(:all) do
      work_with_example(:simple_remoting) do |f|
        @deserializer = Deserializer::Base.new(f)
        @incoming_amf_object = @deserializer.process
        OperationProcessorsManger.add_operation_processor(SpecOperationProcessor)
      end
    end
    
      describe "incoming_amf_object" do
        it('should be_an_instance_of(AMFObject)') {@incoming_amf_object.should be_an_instance_of(AMFObject)}
        it('should have no headers') {@incoming_amf_object.headers.should be_empty}
        it('should have 1 message') { @incoming_amf_object.messages.size.should == 1 }
        it('should declare amf version 0') { @incoming_amf_object.version.should == 0 }
        it('should declare client 3') { @incoming_amf_object.client.should == 3 }
        
        describe "message" do
          before(:all) { @message = @incoming_amf_object.messages.first}
          it('should be an instance of AMFMessage') { @message.should be_an_instance_of(AMFMessage) }
          it('should declare amf version 3') { @message.amf_version.should == 3 }
          it('should declare response uri "/2"') { @message.response_uri.should == "/2" }
          it('should declare length 237') { @message.length.should == 237 }
          it('should declare target_uri "null"') { @message.target_uri.should == "null" }
          
          describe "value" do
            
            before(:all) {@value = @message.value.first}
            it('should be an instance of FlexObjects::RemotingMessage') { @value.should be_an_instance_of(FlexObjects::RemotingMessage) }
            it('should declare timestamp 0') { @value.timestamp.should == 0 }
            it('should declare source nil') { @value.source.should == nil }
            it('should declare headers {:DSEndpoint=>"ramf", :DSId=>"nil"}'){ @value.headers.should == {:DSEndpoint=>'ramf', :DSId=>'nil'} }
            it('should declare clientId nil') { @value.clientId.should == nil }
            it('should declare timeToLive 0') { @value.timeToLive.should == 0 }
            it('should declare messageId "91B3B766-DE81-122D-E7FA-E18B83359EE8"') { @value.messageId.should == "91B3B766-DE81-122D-E7FA-E18B83359EE8" }
            it('should declare body ["3"]') { @value.body.should == ["3"] }
            it('should declare destination "HomeController"') { @value.destination.should == "HomeController" }
            it('should declare operation "getList"') { @value.operation.should == "getList" }
            
          end #RAMF simple_remoting_example incoming_amf_object message value
          
        end #RAMF simple_remoting_example incoming_amf_object message
        
        describe "processed_incoming_amf_object" do
          
          before(:all) {@processed_incoming_amf_object = @incoming_amf_object.process}
          it('should be an instance of AMFObject') {@processed_incoming_amf_object.should be_an_instance_of(AMFObject)}
          it('should declare version 0') {@processed_incoming_amf_object.version.should == 0}
          it('should declare client 3') {@processed_incoming_amf_object.client.should == 3}
          it('should declare headers []') {@processed_incoming_amf_object.headers.should == []}
          it('should have 1 message') {@processed_incoming_amf_object.messages.size.should == 1}
          
          describe "message" do
            
            before(:all) {@message = @processed_incoming_amf_object.messages.first}
            it('should be an instance of AMFMessage') {@message.should be_an_instance_of(AMFMessage)}
            it('should declare amf_version 3') {@message.amf_version.should == 3}
            it('should declare length -1') {@message.length.should == -1}
            it('should declare response_uri ""') {@message.response_uri.should == ""}
            it('should declare target_uri "/2/onResult"') {@message.target_uri.should == "/2/onResult"}
            
            describe "value" do
              before(:all) {@value = @message.value}
              it('should be an instance of FlexObjects::AcknowledgeMessage') {@value.should be_an_instance_of(FlexObjects::AcknowledgeMessage)}
              it('should declare body "HomeController.get_list says hi with args: [\'3\']"') {@value.body.should == "HomeController.get_list says hi with args: [\"3\"]" }
              it('should declare correlationId "91B3B766-DE81-122D-E7FA-E18B83359EE8"') {@value.correlationId.should == "91B3B766-DE81-122D-E7FA-E18B83359EE8" }
              it('should declare messageId in the right form') {@value.messageId.should =~ /^.{8}-.{4}-.{4}-.{4}-.{12}$/ }
            end
            
          end #RAMF simple_remoting_example incoming_amf_object processed_incoming_amf_object message
          
        end #RAMF simple_remoting_example incoming_amf_object processed_incoming_amf_object
        
      end #RAMF simple_remoting_example incoming_amf_object
      
  end #RAMF simple_remoting_example
  
end #RAMF