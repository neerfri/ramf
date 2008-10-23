require File.join(File.dirname(__FILE__),'../spec_helper')

describe RAMF::FlexObjects::ByteArray do
  
  before(:each) {@byte_array = RAMF::FlexObjects::ByteArray.new("content")}
  
  it "should be kind_of IO" do
    @byte_array.should be_kind_of(::Tempfile)
  end
  
  it "should be rewinded" do
    @byte_array.pos.should == 0
  end
end