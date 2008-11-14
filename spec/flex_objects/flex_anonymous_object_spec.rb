require File.join(File.dirname(__FILE__),'../spec_helper')
require 'ruby-debug'
      
class DummyObject
  def initialize
    @dummy_attribute = "dummy"
  end
end


describe RAMF::FlexObjects::FlexAnonymousObject do
  
  it "should extend Hash" do
    RAMF::FlexObjects::FlexAnonymousObject.superclass.should == Hash
  end
  
  describe "to_params method" do
    
    before(:each) do
      @obj = RAMF::FlexObjects::FlexAnonymousObject.new
      @obj.string_attr = "my_string"
      @obj.numeric_attr = 6.5
      @obj.hash_attr = {:some=>"hash"}
      @obj.true_attr = true
      @obj.false_attr = false
      @obj.nil_attr = nil
      @obj.object_attr = DummyObject.new 
    end
    
    it "should return instance of Hash" do
      @obj.to_params.should be_an_instance_of(Hash)
    end
    
    [:string, :numeric, :hash, :true, :false, :nil].each do |type|
      it "should not change objects of type #{type}" do
        @obj.to_params["#{type}_attr".to_sym].should == @obj.send("#{type}_attr")
      end
    end
    
    it "should convert objects to hash" do
      @obj.to_params[:object_attr].should == {:dummy_attribute=>"dummy"}
    end
    
  end
end
