class User
  attr_accessor :created_on, :alien, :name, :update_profile, 
                :preferences, :referer_id, :fb_removed_on, 
                :facebook_uid, :id, :last_visit, :facebook_session_key,
                :limited, :screen_name, :password, :email, :email_confirmed
end


describe 'deserializer1.bin' do
  before(:all) do
    @amf_object = deserialize_from_file('deserializer2.bin')
  end
  
  it 'should have the right properties' do
#    p @amf_object
#    p @amf_object.messages[0].value[0]._explicitType
    @amf_object.version.should be(0)
    @amf_object.client.should be(3)
  end
  
  it 'should have 1 header' do
    @amf_object.headers.size.should be(1)
  end
#  
#  it 'should have a header with the right properties' do
#    @amf_object.headers[0].value.should == {:userid=>"13", :password=>"1234"}
#    @amf_object.headers[0].name.should == "Credentials"
#    @amf_object.headers[0].must_understand.should be(0)
#  end
#  
  it 'should have 1 message' do
    @amf_object.messages.size.should be(1)
  end
#  
#  it 'should have a message with the right properties' do
#    @amf_object.messages[0].target_uri.should eql("AdminController.testMethod")
#    @amf_object.messages[0].response_uri.should eql("/1")
#    @amf_object.messages[0].value.should eql(["param1","param2"])
#  end
end