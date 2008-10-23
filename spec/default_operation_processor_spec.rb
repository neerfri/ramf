require File.join(File.dirname(__FILE__),'spec_helper')

describe RAMF::DefaultOperationProcessor do
  
  it "should be registered in RAMF::OperationProcessorsManager" do
    RAMF::OperationProcessorsManager::OPERATION_PROCCESSORS.last.should == RAMF::DefaultOperationProcessor
  end
  
  it "should process all requests" do
    RAMF::DefaultOperationProcessor.will_process?(nil).should be_true
  end
  
  it "should raise OperationProcessorNotDefined when ever asked to process" do
    lambda {RAMF::DefaultOperationProcessor.process(nil)
            }.should raise_error(RAMF::DefaultOperationProcessor::OperationProcessorNotDefined)
  end
  
end