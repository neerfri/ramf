require File.join(File.dirname(__FILE__),'spec_helper')
require 'rexml/document'

describe RAMF::Serializer::Base do
  
  before(:all) do
    @serializer = RAMF::Serializer::Base.new(3)
  end
  
  describe '@encoded_object(Example 1)' do
    
    before(:all) do
      @amfobject = RAMF::AMFObject.new
      value = RAMF::FlexObjects::FlexAnonymousObject.new
      value.string_attribute = "some string"
      value.double_attribute = 34.523
      value.integer_attribute = 5
      value.symbol_attribute = :some_symbol
      value.time_attribute = Time.now
      value.date_attribute = Date.today
      value.xml_attribute = REXML::Document.new("<xml><e>1</e><e>2</e></xml>")
      value.byte_array_attribute = StringIO.new("Some Binary Stream To Serialize")
      @amfobject.add_message new_amf_message(value)
      amf_string = @serializer.write(@amfobject)
#      p amf_string
#      File.open('debug/output.bin',"w+") {|f| f.print(amf_string)}
      @deserializer = RAMF::Deserializer::Base.new(StringIO.new(amf_string))
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
    
    it 'should respond_to :date_attribute with Date.today' do
      @encoded_object.date_attribute.day.should == Date.today.day
      @encoded_object.date_attribute.month.should == Date.today.month
      @encoded_object.date_attribute.year.should == Date.today.year
    end
    
    it 'should respond_to :time_attribute with the right time' do
      @encoded_object.time_attribute.utc.sec.should == @amfobject.messages[0].value.time_attribute.sec
      @encoded_object.time_attribute.utc.min.should == @amfobject.messages[0].value.time_attribute.min
      @encoded_object.time_attribute.utc.hour.should == @amfobject.messages[0].value.time_attribute.hour
      @encoded_object.time_attribute.utc.day.should == @amfobject.messages[0].value.time_attribute.day
      @encoded_object.time_attribute.utc.month.should == @amfobject.messages[0].value.time_attribute.month
      @encoded_object.time_attribute.utc.year.should == @amfobject.messages[0].value.time_attribute.year
    end
    
    it 'should respond_to :xml_attribute with the right XML' do
      @encoded_object.xml_attribute.to_s.should == @amfobject.messages[0].value.xml_attribute.to_s
    end
    
    it 'should respond_to :byte_array_attribute with a RAMF::FlexObjects::ByteArray instance' do
      @encoded_object.byte_array_attribute.should be_an_instance_of(RAMF::FlexObjects::ByteArray)
    end
    
    it ':byte_array_attribute attribute should be a stream containing "Some Binary Stream To Serialize"' do
      @encoded_object.byte_array_attribute.read.should == "Some Binary Stream To Serialize"
    end
    
  end
    
  
end

def new_amf_message(value)
  RAMF::AMFMessage.new(:target_uri=>"1\onResult",
                       :response_uri=>"null",
                       :value=>value)
end