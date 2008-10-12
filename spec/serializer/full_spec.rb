require File.join(File.dirname(__FILE__),'../spec_helper')
require 'rexml/document'

#This spec checks RAMF::Serializer::Base, this means it uses large scale examples to check the
#overal functionality of the serialization process
describe RAMF::Serializer::Base do
  
  before(:all) do
    @serializer = RAMF::Serializer::Base.new
  end
  
  describe 'header serialization' do
    
    before(:all) do
      @amfobject = RAMF::AMFObject.new
      header = RAMF::AMFHeader.new("TestHeader",[1,2],true)
      @amfobject.add_header header
      @amfobject.add_message new_amf_message(nil)
      amf_string = @serializer.write(@amfobject)
      @deserializer = RAMF::Deserializer::Base.new(StringIO.new(amf_string))
      @response = @deserializer.process
      @header = @response.get_header_by_key("TestHeader")
    end
    
    it 'should have a header named "TestHeader"' do
      @header.name.should == "TestHeader"
    end
    
    describe "TestHeader" do
    
      it 'should have value [1, 2]' do
        @header.value.should == [1,2]
      end
      
      it 'should be a must-understand' do
        @header.must_understand.should == 1
      end
      
    end
    
  end
  
  describe '@encoded_object(Example 1)' do
    
    before(:all) do
      @amfobject = RAMF::AMFObject.new
      value = RAMF::FlexObjects::FlexAnonymousObject.new
      value.string_attribute = "some string"
      value.double_attribute = 34.523
      value.integer_attribute = 5
      value.symbol_attribute = :some_symbol
      value.array_attribute = [16300, 2097000, 268435400]
      value.time_attribute = Time.now
      value.true_attribute = true
      value.false_attribute = false
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
    
    it 'should respond to array_attribute with [16300, 2097000, 268435400]' do
      @encoded_object.array_attribute.should == [16300, 2097000, 268435400]
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
      @encoded_object.byte_array_attribute.instance_of?(RAMF::FlexObjects::ByteArray).should be_true
    end
    
    it ':byte_array_attribute attribute should be a stream containing "Some Binary Stream To Serialize"' do
      @encoded_object.byte_array_attribute.read.should == "Some Binary Stream To Serialize"
    end
    
    it 'should respond_to :true_attribute with true' do
      @encoded_object.true_attribute.should == true
    end
    
    it 'should respond_to :false_attribute with false' do
      @encoded_object.false_attribute.should == false
    end
    
  end
  
  
  
  describe '@encoded_object(Example 2)' do
    
    class SerializerTestObject
      attr_accessor :rw_attr
      attr_writer :w_attr
      
      flex_remoting_members :fixed_method
      
      def fixed_method
        "fixed_method"
      end
    end
    
    
    before(:all) do
      @amfobject = RAMF::AMFObject.new
      value = SerializerTestObject.new
      value.rw_attr = "read-write attribute"
      value.w_attr = "write-only attribute"
      @amfobject.add_message new_amf_message(value)
      amf_string = @serializer.write(@amfobject)
#      p amf_string
#      File.open('debug/output.bin',"w+") {|f| f.print(amf_string)}
      @deserializer = RAMF::Deserializer::Base.new(StringIO.new(amf_string))
      @response = @deserializer.process
      @encoded_object = @response.messages[0].value
    end
    
    it 'should respond_to :rw_attr with "read-write attribute"' do
      @encoded_object.rw_attr.should == "read-write attribute"
    end
    
  end
  
    
  def new_amf_message(value)
    RAMF::AMFMessage.new(:target_uri=>'1\onResult',
                         :response_uri=>"null",
                         :value=>value)
  end
  
end
