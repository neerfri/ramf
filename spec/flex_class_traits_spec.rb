require File.join(File.dirname(__FILE__),'spec_helper')

class DummyClass
  
  
  
  def initialize
    @some_attribute = "attribute"
  end
end

describe RAMF::FlexClassTraits do
  
  after(:each) do
    DummyClass.instance_variable_set('@flex_remoting',nil)
    RAMF::FlexClassTraits::KNOWN_CLASSES.delete("DummyClass")
  end
  
  it 'sholud return the class\'s name' do
    DummyClass.flex_remoting.name.should eql("DummyClass")
  end
  
  it 'should return the class\'s sealed members' do
    DummyClass.flex_remoting_members :some_attribute
    DummyClass.flex_remoting.members.should include(:some_attribute)
  end
  
  it 'should raise an error when there is a duplicate ACtionScript class name' do
    StandardError.flex_remoting
    lambda {
    DummyClass.flex_remoting.name = "StandardError"
    }.should raise_error
  end
  
  it 'should give you a smalll meal and a tight seat when you are in economy' do
    DummyClass.flex_remoting_scope :economy, :only=>[:small_meal, :tight_seat]
    DummyClass.flex_remoting.members(:economy).should eql([:small_meal, :tight_seat])
  end
  
  it 'should be a dynamic object by default' do
    DummyClass.flex_remoting.is_dynamic.should be(true)
  end
  
end