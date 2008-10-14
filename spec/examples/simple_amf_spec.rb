require File.join(File.dirname(__FILE__),'../spec_helper')
require File.join(File.dirname(__FILE__),'examples_helper')
include RAMF
include ExampleHelper

describe "RAMF" do
  
  #This is a simple amf request (not messaging) with credentials supplied in the headers of the AMFObject
  describe "simple_amf1" do
    
    before(:all) do
      work_with_example(:simple_amf1) do |f|
        @deserializer = Deserializer::Base.new(f)
        @incoming_amf_object = @deserializer.process
        OperationProcessorsManger.add_operation_processor(ExampleHelper::OperationProcessor)
      end
    end
    
    describe "incoming_amf_object" do
      incoming_amf_object_examples(:headers=>1, :messages=>1)
      
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
        incoming_amf_object_message_examples(:response_uri=>"/1", :length=>23, :target_uri=>"AdminController.testMethod")
        it('should declare value ["param1", "param2"]') { @message.value.should == ["param1", "param2"]}
      end
      
      describe "processed_incoming_amf_object" do
        before(:all) {@processed_incoming_amf_object = @incoming_amf_object.process}
        processed_incoming_amf_object_examples
        
        describe "message" do
          before(:all) {@message = @processed_incoming_amf_object.messages.first}
          processed_incoming_amf_object_message_examples(:target_uri=>"/1/onResult")
          it('should declare value "SimpleAMF: AdminController.test_method with credentials {:password=>\"1234\", :userid=>\"13\"}"') {
                            @message.value.should == "SimpleAMF: AdminController.test_method with credentials {:password=>\"1234\", :userid=>\"13\"}"}
          
        end #RAMF simple_amf_example incoming_amf_object processed_incoming_amf_object message
        
      end #RAMF simple_amf_example incoming_amf_object processed_incoming_amf_object
      
    end #RAMF simple_amf_example incoming_amf_object
      
  end #RAMF simple_amf_example
  
end #RAMF
