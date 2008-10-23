require File.join(File.dirname(__FILE__),'../spec_helper')

describe Object do
  
  before(:each) do
    @object = Object.new
    @object.instance_variable_set("@instance_var","instance_var")
#    @object.class.flex_remoting_members :member
  end
  
  describe "flex_members_reader" do
    it "should use a setter with same name" do
      @object.should_receive(:send).with(:member)
      @object.class.flex_remoting.members_reader.call(@object, :member)
    end
  end
  
  describe "flex_members_writer" do
    it "should call a method 'member='" do
      @object.should_receive(:send).with("member=","value")
      @object.stub!(:respond_to?).and_return(true)
      @object.class.flex_remoting.members_writer.call(@object, :member, "value")
    end
    
    it "should set an instance variable if no setter is available" do
      @object.should_receive(:instance_variable_set).with("@member","value")
      @object.stub!(:respond_to?).and_return(false)
      @object.class.flex_remoting.members_writer.call(@object, :member, "value")
    end
  end
  
  describe "flex_dynamic_members_finder" do
    it "should find instance variables" do
      @object.class.flex_remoting.dynamic_members_finders.first.call(@object, :default).should == [:instance_var]
    end
  end
  
  describe "flex_dynamic_members_reader" do
    it "should use getter when object responds to :member" do
      @object.should_receive(:send).with(:member)
      @object.stub!(:respond_to?).and_return(true)
      @object.class.flex_remoting.dynamic_members_reader.call(@object, :member)
    end
    
    it "should pull value from instance variable when one is defined" do
      @object.should_receive(:instance_variable_get).with("@member")
      @object.stub!(:instance_variable_defined?).and_return(true)
      @object.class.flex_remoting.dynamic_members_reader.call(@object, :member)
    end
    
    it "should pull value from [] when object responds to it" do
      @object.should_receive(:[]).with(:member)
      @object.stub!(:respond_to?).with(:member).and_return(false)
      @object.stub!(:respond_to?).with(:[]).and_return(true)
      @object.class.flex_remoting.dynamic_members_reader.call(@object, :member)
    end
    
    it "should try to use a setter when everything else fails" do
      @object.stub!(:respond_to?).with(:member).and_return(false)
      @object.stub!(:instance_variable_defined?).and_return(false)
      @object.stub!(:respond_to?).with(:[]).and_return(false)
      @object.should_receive(:send).with(:member)
      @object.class.flex_remoting.dynamic_members_reader.call(@object, :member)
    end
    
    it "should issue a warning and return nil when all methods fail" do
      @object.stub!(:respond_to?).with(:member).and_return(false)
      @object.stub!(:instance_variable_defined?).and_return(false)
      @object.stub!(:respond_to?).with(:[]).and_return(false)
      Object.should_receive(:warn)
      @object.should_receive(:send).with(:member).and_raise(NoMethodError)
      @object.class.flex_remoting.dynamic_members_reader.call(@object, :member).should == nil
    end
    
  end
  
  describe "flex_dynamic_members_writer" do
    it "should use a setter with same name" do
      @object.should_receive(:send).with("member=", "value")
      @object.class.flex_remoting.dynamic_members_writer.call(@object, :member, "value")
    end
  end
  
  describe "returning method" do
    it "should respond to :returning" do
      @object.should respond_to(:returning)
    end
    
    it "should pass the argument to the block" do
      returning(@object) {|obj| obj.should == @object}
    end
    
    it "should return the first argument" do
      returning(@object){}.should == @object
    end
    
  end
  
  
end