module RAMF
  module FlexObjects
    class FlexObject < FlexAnonymousObject
  
      attr_reader :_explicitType
      
      def initialize(_explicitType)
        @_explicitType = _explicitType
      end
    end
  end
end