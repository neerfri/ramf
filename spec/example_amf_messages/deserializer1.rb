describe 'deserializer1.bin' do
  before(:all) do
    @amf_object = deserialize_from_file('deserializer1.bin')
  end
  
  it 'should have the right properties' do
    @amf_object.version.should be(0)
    @amf_object.client.should be(3)
  end
  
  it 'should have 1 header' do
    @amf_object.headers.size.should be(1)
  end
  
  it 'should have a header with the right properties' do
    header = @amf_object.get_header_by_key("Credentials")
    header.value.should == {:userid=>"13", :password=>"1234"}
    header.name.should == "Credentials"
    header.must_understand.should be(0)
  end
  
  it 'should have 1 message' do
    @amf_object.messages.size.should be(1)
  end
  
  it 'should have a message with the right properties' do
    @amf_object.messages[0].target_uri.should eql("AdminController.testMethod")
    @amf_object.messages[0].response_uri.should eql("/1")
    @amf_object.messages[0].value.should eql(["param1","param2"])
  end
end