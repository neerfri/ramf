class RAMF::OperationProcessorsManger
  OPERATION_PROCCESSORS = []
  
  #A wrapper class to let our caller know we had problems in processing the operation request
  class ErrorWhileProcessing < StandardError
    attr_accessor :original_exception
    def initialize(message, original_exception)
      super(message)
      @original_exception = original_exception
    end
  end
  
  class << self
    def process(operation, headers, processor)
      return operation.response if operation.ping?
      #invoke action
      processor ||= OPERATION_PROCCESSORS.find {|p| p.will_process?(operation)}
      begin
        operation.response(processor.process(operation))
      rescue Exception=>e
        raise ErrorWhileProcessing.new("Exception raise while tring to process operation with #{processor}", e)
      end
    end
    
    def add_operation_processor(processor)
      OPERATION_PROCCESSORS.delete(processor)
      OPERATION_PROCCESSORS.unshift(processor)
    end
  end
end