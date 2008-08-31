require File.join(File.dirname(__FILE__),'spec_helper')

describe RAMF::Serializer::Base do
  
  before(:all) do
    @serializer = RAMF::Serializer::Base.new(3)
  end
  
  describe '@encoded_object(Example 1)' do
    
    before(:each) do
      @amfobject = RAMF::AMFObject.new
      value = RAMF::FlexObjects::FlexAnonymousObject.new
      value.string_attribute = "some string"
      value.double_attribute = 34.523
      value.integer_attribute = 5
      value.symbol_attribute = :some_symbol
      @amfobject.add_message new_amf_message(value)
#     File.open('debug/output.bin',"w+") {|f| f.print(amf_string)}
      @deserializer = RAMF::Deserializer::Base.new(StringIO.new(@serializer.write(@amfobject)))
      @response = @deserializer.process
      @encoded_object = @response.messages[0].value
    end
    
    it 'should return a flex anonymous object' do
      @encoded_object.should be_instance_of(RAMF::FlexObjects::FlexAnonymousObject)
    end
    
    it 'should respond to :string_attribute with "some string"' do
      @encoded_object.string_attribute.should == "some string"
    end
    
    it 'should respond to :symbol_attribute with "some_symbol"' do
      @encoded_object.symbol_attribute.should == "some_symbol"
    end
    
    it 'should respond to :integer_attribute with 5' do
      @encoded_object.integer_attribute.should == 5
    end
    
    it 'should respond to :double_attribute with 34.523' do
      @encoded_object.double_attribute.should == 34.523
    end
  end
    
  
end

def new_amf_message(value)
  RAMF::AMFMessage.new(:target_uri=>"1\onResult",
                       :response_uri=>"null",
                       :value=>value)
end