module RAMF
  class AMFHeader
    attr_accessor :name, :value, :must_understand, :length
    
    def initialize(name,value,must_understand, length = -1)
      @name, @value, @must_understand, @length = name, value, must_understand, length
    end
  end
end