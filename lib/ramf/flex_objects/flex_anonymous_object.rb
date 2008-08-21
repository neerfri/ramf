module RAMF
  module FlexObjects
    class FlexAnonymousObject < Hash
      attr_accessor :remoting_copy
      
      def initialize
        @remoting_copy = {}
        @remoting_copy[:name] = ""
      end
      
    end
  end
end
