require File.join(File.dirname(__FILE__),'spec_helper')
include RAMF

describe OperationProcessorsManager do
  before(:all) do
    @opm = OperationProcessorsManager
    @processor = mock("Processor")
    @opm.add_operation_processor(@processor)
  end
  
  describe "process method" do
    before(:each) do
      @operation = mock("operation", :ping? => false)
      @arg1 = mock("arg1")
      @arg2 = mock("arg2")
      @operation.stub!(:response).with("PROCESSED").and_return("RESPONSE")
      @processor.stub!(:will_process?).and_return(true)
      @processor.stub!(:process).and_return("PROCESSED")
    end
    
    it('should return value when operation is a ping') do
      @operation.stub!(:ping?).and_return(true)
      @operation.stub!(:response).with().and_return("PING")
      @opm.process(@operation, @arg1, @arg2).should == "PING"
    end
    
    it('should look for a processor to handle the request') do
      @opm.process(@operation, @arg1, @arg2).should == "RESPONSE"
    end
    
    it 'should raise a custom error when the processor fails' do
      @processor.stub!(:process).and_raise(StandardError.new('processing error'))
      lambda {@opm.process(@operation, @arg1, @arg2)}.should raise_error(OperationProcessorsManager::ErrorWhileProcessing)
    end
    
    it 'should attach the original error to the exception object' do
      @exception = StandardError.new('processing error')
      @processor.stub!(:process).and_raise(@exception)
      begin
        @opm.process(@operation, @arg1, @arg2)
      rescue OperationProcessorsManager::ErrorWhileProcessing=>e
        e.original_exception.should == @exception
      end
    end
    
  end
  
  describe "add_operation_processor method" do
    
    it 'should delete a previous appearance of the processor' do
      OperationProcessorsManager::OPERATION_PROCCESSORS.should_receive(:delete)
      @opm.add_operation_processor(@processor)
    end
    
    it 'should unshift the processor to the array' do
      OperationProcessorsManager::OPERATION_PROCCESSORS.should_receive(:unshift)
      @opm.add_operation_processor(@processor)
    end
    
  end
end