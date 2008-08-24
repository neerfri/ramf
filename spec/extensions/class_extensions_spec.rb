require File.join(File.dirname(__FILE__),'../spec_helper')

class DummyClass;end;
describe Class do 
  
  after(:each) do
    DummyClass.instance_variable_set('@flex_remoting',nil)
    RAMF::FlexClassTraits::KNOWN_CLASSES.delete("DummyClass")
  end
  
  it 'should have flex_remoting marked as a transient member' do
    DummyClass.flex_remoting.transient_members.should include(:flex_remoting)
  end
  
  it 'should get a default name accurding to the class name' do
    DummyClass.flex_remoting.name.should eql("DummyClass")
  end
  
  describe 'flex_remoting' do
    it 'should return an instance of RAMF::FlexClassTraits' do
      DummyClass.flex_remoting.should be_an_instance_of(RAMF::FlexClassTraits)
    end
  end
  
  describe 'flex_remoting_transient' do
    it 'should add transient members' do
      DummyClass.flex_remoting_transient(:secret_attribute, :stupid_attribute)
      DummyClass.flex_remoting.transient_members.should include(:secret_attribute)
      DummyClass.flex_remoting.transient_members.should include(:stupid_attribute)
    end    
  end
  
  describe 'flex_alias' do
    it 'should change the remote name of the class' do
      DummyClass.flex_alias :ActionScriptDummyClass
      DummyClass.flex_remoting.name.should eql("ActionScriptDummyClass")
      RAMF::FlexClassTraits::KNOWN_CLASSES.delete("ActionScriptDummyClass")
    end
  end
  
  describe 'flex_remoting_scope' do
    it 'should add exceptions to scope :limited' do
      DummyClass.flex_remoting_scope :limited, :except=>[:phone,:email]
      DummyClass.flex_remoting.amf_scope_options[:limited][:except].should include(:phone)
      DummyClass.flex_remoting.amf_scope_options[:limited][:except].should include(:email)
    end
    
    it 'should define members to scope :private' do
      DummyClass.flex_remoting_scope :private, :only=>[:fullname, :nickname]
      DummyClass.flex_remoting.amf_scope_options[:private][:only].should include(:fullname)
      DummyClass.flex_remoting.amf_scope_options[:private][:only].should include(:nickname)
    end
    
    it 'should raise an error when both :only and :except are sent together' do
      lambda {
        DummyClass.flex_remoting_scope :limited, :except=>[:phone,:email], :only=>[:phone]
      }.should raise_error(RuntimeError)
    end
  end
  
  
end