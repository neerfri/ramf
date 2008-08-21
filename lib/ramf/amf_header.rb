module RAMF
  class AMFHeader
    attr_accessor :name, :value, :must_understand
    
    def initialize(name,value,must_understand)
      @name, @value, @must_understand = name, value, must_understand
    end
  end
end