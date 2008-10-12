require File.join(File.dirname(__FILE__),'../spec_helper')

describe RAMF::Serializer::Base do
  before(:each) do
    @serializer = RAMF::Serializer::Base.new
    @stream = @serializer.instance_variable_get("@stream")
  end
  
  describe "write method" do
    before(:each) do
      @amf_object = RAMF::AMFObject.new :version=>RAMF::AMFObject::AMF3_VERSION,
                                        :client=>RAMF::AMFObject::FP9_CLIENT,
                                        :headers => [:header,:header],
                                        :messages => [:message]
      @method = @serializer.method(:write)
    end
    
    it "should write the amf version(3), header count(2) and message count(1)" do
      @serializer.stub!(:write_header)
      @serializer.stub!(:write_message)
      @method.call(@amf_object).should == "\000\003\000\002\000\001"
    end
    
    it "should call write_header 3 times" do
      @serializer.should_receive(:write_header).with(:header, :default).exactly(2).times
      @serializer.stub!(:write_message)
      @method.call(@amf_object)
    end
    
    it "should call write_message 3 times" do
      @serializer.should_receive(:write_message).with(:message, :default).exactly(1).times
      @serializer.stub!(:write_header)
      @method.call(@amf_object)
    end
  end #write method
  
  describe "write_header method" do
    before(:each) do
      @header = RAMF::AMFHeader.new("HEADER_NAME","VALUE",true)
      @method = @serializer.method(:write_header)
      @amf0_writer = stub("AMF0Writer", :write_value_type=>nil)
      RAMF::Serializer::AMF0Writer.stub!(:new).and_return(@amf0_writer)
    end
    
    it "should write the header name, must_understand and length" do
      @method.call(@header, :default)
      @stream.rewind
      @stream.read.should == "\000\vHEADER_NAME\001\377\377\377\377"
    end
    
    it "should use AMF0Writer to write the header value" do
      @amf0_writer.should_receive(:write_value_type).with(@header.value,@stream)
      @method.call(@header, :default)
    end
  end #write_header method
  
  describe "write_message method" do
    before(:each) do
      @message = RAMF::AMFMessage.new :target_uri=>"TARGET_URI",
                                      :value=>"VALUE"
      @method = @serializer.method(:write_message)
      @amf0_writer = stub("AMF0Writer", :write_value_type=>nil)
      @amf3_writer = stub("AMF3Writer", :write_value_type=>nil)
      RAMF::Serializer::AMF0Writer.stub!(:new).and_return(@amf0_writer)
      RAMF::Serializer::AMF3Writer.stub!(:new).and_return(@amf3_writer)
    end
    
    it "should write the message target_uri, response_uri and length" do
      @message.stub!(:amf_version).and_return(1)
      @method.call(@message, :default)
      @stream.rewind
      @stream.read.should == "\000\nTARGET_URI\000\004null\377\377\377\377"
    end
    
    it "should use AMF0Writer to write the message value when in AMF0 mode" do
      @message.stub!(:amf_version).and_return(0)
      @amf0_writer.should_receive(:write_value_type).with(@message.value,@stream)
      @method.call(@message, :default)
    end
    
    it "should use AMF3Writer to write the message value when in AMF3 mode" do
      @message.stub!(:amf_version).and_return(3)
      @serializer.stub!(:writeUTF8)
      @serializer.stub!(:writeU32)
      @stream.should_receive(:write).with(RAMF::IO::Constants::AMF3_TYPE_MARKER)
      @amf3_writer.should_receive(:write_value_type).with(@message.value,@stream)
      @method.call(@message, :default)
    end
  end #write_message method
  
  
end