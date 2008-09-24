require File.join(File.dirname(__FILE__),'../spec_helper')

describe RAMF::Serializer::AMF3Writer do
  
  describe 'calculate_integer_U29 method' do
    before(:all) do
      @method = RAMF::Serializer::AMF3Writer.new.method(:calculate_integer_U29)
    end
    
    it 'should return "\000" for 0' do
      @method.call(0).should == "\000"
    end
    
    it 'should return "\177" for 127' do
      @method.call(127).should == "\177"
    end
    
    it 'should return "\377\177" for 16383' do
      @method.call(16383).should == "\377\177"
    end
    
    it 'should return "\377\377\177" for 2097151' do
      @method.call(2097151).should == "\377\377\177"
    end
    
    it 'should return "\377\377\377\377" for 536870911' do
      @method.call(536870911).should == "\377\377\377\377"
    end
        
  end
end