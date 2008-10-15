require File.join(File.dirname(__FILE__),'spec_helper')

describe RAMF::AMFObject do
  before(:each) do
    @amf_object = RAMF::AMFObject.new
  end
  
  describe "process method" do
    before(:each) do
      @operation1 = stub("OperationRequest1")
      @operation2 = stub("OperationRequest2")
      @message1 = stub("AMFMessage", :to_operation=>@operation1, :response_uri=>"1")
      @message2 = stub("AMFMessage", :to_operation=>@operation2, :response_uri=>"2")
      @amf_object.add_message(@message1)
      @amf_object.add_message(@message2)
      RAMF::OperationProcessorsManger.stub!(:process).with(@operation1, [], nil).and_return(1)
      RAMF::OperationProcessorsManger.stub!(:process).with(@operation2, [], nil).and_return(2)
      @method = @amf_object.method(:process)
    end
    
    it "should call RAMF::OperationProcessor.process to process the OperationRequest" do
      RAMF::OperationProcessorsManger.should_receive(:process).with(@operation1, [], nil)
      RAMF::OperationProcessorsManger.should_receive(:process).with(@operation2, [], nil)
      @method.call
    end
    
    describe "returned value" do
      it "should be an instance of AMFObject" do
        @method.call.should be_an_instance_of(RAMF::AMFObject)
      end
      
      it "should contain same number of messages" do
        @method.call.messages.size.should == 2
      end
      
      it 'should contain message with target_uri "1/onResult" with the right value' do
        message = @method.call.messages.find{|m| m.target_uri == "1/onResult"}
        message.should_not be_nil
        message.value.should == 1
      end
      
      it 'should contain message with target_uri "2/onResult" with the right value' do
        message = @method.call.messages.find{|m| m.target_uri == "2/onResult"}
        message.should_not be_nil
        message.value.should == 2
      end
      
      it "should contain one message with Exception when exception was raised in processing" do
        exception = RAMF::OperationProcessorsManger::ErrorWhileProcessing.new("", StandardError.new)
        RAMF::OperationProcessorsManger.should_receive(:process).with(@operation1, [], nil).and_raise(exception)
        @operation1.should_receive(:exception_response).and_return(StandardError.new)
        messages = @method.call.messages.select{|m| m.target_uri[-8,8] == "onStatus"}
        messages.size.should == 1
        messages.first.should_not be_nil
        messages.first.value.should be_an_instance_of(StandardError)
      end
    end
    
  end #process method
  
  describe "credentials_header method" do
    before(:each) do 
      @method = @amf_object.method(:credentials_header)
    end
    
    describe "returned value" do
      it "should be {:userid => nil, :password => nil}" do
        @method.call.should == {:userid => nil, :password => nil}
      end
      
      it "should be {:userid => 'my_user', :password => 'my_password'}" do
        @amf_object.add_header(stub("AMFHeader", :name=>"Credentials", :value=>{:userid=>'my_user', :password => 'my_password'}))
        @method.call.should == {:userid => 'my_user', :password => 'my_password'}
      end
      
    end
  end #credentials_header method
end