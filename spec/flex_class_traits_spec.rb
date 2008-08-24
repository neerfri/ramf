require File.join(File.dirname(__FILE__),'spec_helper')

class DummyClass
  flex_remoting_members :some_attribute
  flex_remoting_scope :economy, :only=>[:small_meal, :tight_seat]
  
  def initialize
    @some_attribute = "attribute"
  end
end

describe RAMF::FlexClassTraits do
  it 'sholud return the class\'s name' do
    DummyClass.flex_remoting.name.should eql("DummyClass")
  end
  
  it 'should return the class\'s sealed members' do
    DummyClass.flex_remoting.members.should include(:some_attribute)
  end
  
  it 'should raise an error when there is a duplicate ACtionScript class name' do
    Object.flex_remoting
    DummyClass.flex_remoting.name = "Object"
  end
  
  it 'should give you a smalll meal and a tight seat when you are in economy' do
    DummyClass.flex_remoting.members(:economy).should eql([:small_meal, :tight_seat])
  end
  
  it 'should be a dynamic object by default' do
    DummyClass.flex_remoting.is_dynamic.should be(true)
  end
  
end