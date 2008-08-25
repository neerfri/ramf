require File.join(File.dirname(__FILE__),'spec_helper')

describe RAMF::Deserializer::Base do
  
  before(:all) do
    @amfobject = RAMF::AMFObject.new
    @serializer = RAMF::Serializer::Base.new(3)
  end
    
  it 'should work' do
    value = RAMF::FlexObjects::FlexAnonymousObject.new
    value.attr1 = "1abc"
    value.attr2 = "false"
    @amfobject.add_message new_amf_message(value)
    #TODO: check that the message is good
    @serializer.write(@amfobject)
  end
  
end

def new_amf_message(value)
  RAMF::AMFMessage.new(:target_uri=>"1\onResult",
                       :response_uri=>"null",
                       :value=>value)
end