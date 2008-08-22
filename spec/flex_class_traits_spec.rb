require File.join(File.dirname(__FILE__),'spec_helper')

class DummyClass
  flex_remoting_members :some_attribute
  def initialize
    @some_attribute = "attribute"
  end
end;

describe RAMF::FlexClassTraits do
  it 'sholud return the class\'s name' do
    DummyClass.flex_remoting.name.should eql("DummyClass")
  end
  
  it 'should return the class\'s sealed members' do
    DummyClass.flex_remoting.members.should include(:some_attribute)
  end
  
  
end