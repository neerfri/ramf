class RAMF::OperationProcessor
  
  class << self
    def process(operation, headers)
      return operation.response if operation.ping?
      #invoke action
      v = operation.credentials[:userid] == "myUsername" ? "OK" : "NOAUTH"
      operation.response(v)
    end
  end
end