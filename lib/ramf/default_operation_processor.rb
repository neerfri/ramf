class RAMF::DefaultOperationProcessor
  class OperationProcessorNotDefined <StandardError; end;
  
  #Add self to the operation processors manger list
  RAMF::OperationProcessorsManger.add_operation_processor(self)
  
  
  class << self
    
    #This processor answers all requests, so it will always return true
    def will_process?(operation)
      true
    end
    
    #raise a fault saying there is no processor to handle the operation. 
    def process(operation)
      raise(OperationProcessorNotDefined, "No Operation processor found to process #{operation.inspect}")
    end
  end
end