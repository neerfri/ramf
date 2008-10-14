require File.join(File.dirname(__FILE__),'../spec_helper')
include RAMF

require 'ruby-debug'

describe "RAMF" do
  
  #This is a simple amf request (not messaging) with credentials supplied in the headers of the AMFObject
  describe "simple_amf1" do
    
    before(:all) do
      work_with_example(:simple_amf1) do |f|
        @deserializer = Deserializer::Base.new(f)
        @incoming_amf_object = @deserializer.process
        OperationProcessorsManger.add_operation_processor(SpecOperationProcessor)
      end
    end
    
    describe "incoming_amf_object" do
      it('should be_an_instance_of(AMFObject)') {@incoming_amf_object.should be_an_instance_of(AMFObject)}
      it('should have 1 header') {@incoming_amf_object.headers.size.should == 1}
      it('should have 1 message') { @incoming_amf_object.messages.size.should == 1 }
      it('should declare amf version 0') { @incoming_amf_object.version.should == 0 }
      it('should declare client 3') { @incoming_amf_object.client.should == 3 }
      
      
      describe "first_header" do
        before(:all) {@header = @incoming_amf_object.headers.first}
        it('should be an instance of AMFHeader') { @header.should be_an_instance_of(AMFHeader)}
        it('should declare name "Credentials"') { @header.name.should == "Credentials"}
        it('should declare must_understand 0') { @header.must_understand.should == 0}
        it('should declare length 31') { @header.length.should == 31}
        it('should declare value {:userid=>"13", :password=>"1234"}') { @header.value.should == {:userid=>"13", :password=>"1234"}}
      end #RAMF simple_amf_example incoming_amf_object first_header
      
      describe "first_message" do
        before(:all) {@message = @incoming_amf_object.messages.first}
        it("should be an instance of AMFMessage"){ @message.should be_an_instance_of(AMFMessage)}
        it('should declare value ["param1", "param2"]') { @message.value.should == ["param1", "param2"]}
        it('should declare target_uri "AdminController.testMethod"') { @message.target_uri.should == "AdminController.testMethod"}
        it('should declare amf_version 3') { @message.amf_version.should == 3}
        it('should declare response_uri "/1"') { @message.response_uri.should == "/1"}
        it('should declare length 23') { @message.length.should == 23}
        
      end
      
      
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
          it('should declare target_uri "/1/onResult"') {@message.target_uri.should == "/1/onResult"}
          it('should declare value "Hello, 13, AdminController.test_method says hi with args: [\"param1\", \"param2\"]"') {
                            @message.value.should == "Hello, 13, AdminController.test_method says hi with args: [\"param1\", \"param2\"]"}
          
        end #RAMF simple_amf_example incoming_amf_object processed_incoming_amf_object message
        
      end #RAMF simple_amf_example incoming_amf_object processed_incoming_amf_object
      
    end #RAMF simple_amf_example incoming_amf_object
      
  end #RAMF simple_amf_example
  
end #RAMF
