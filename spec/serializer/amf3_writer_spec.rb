require File.join(File.dirname(__FILE__),'../spec_helper')

describe "AMF3Writer" do
  
  before(:each) do
    @writer = RAMF::Serializer::AMF3Writer.new(:default)
    @stream = StringIO.new
  end
  
  describe 'calculate_integer_U29 method' do
    before(:each) do
      @method = @writer.method(:calculate_integer_U29)
    end
    
    it 'should return "\000" for 0' do
      @method.call(0).should == "\000"
    end
    
    it 'should return "\177" for 127' do
      @method.call(127).should == "\177"
    end
    
    it 'should return "\377\177" for 16383' do
      @method.call(16383).should == "\377\177"
    end
    
    it 'should return "\377\377\177" for 2097151' do
      @method.call(2097151).should == "\377\377\177"
    end
    
    it 'should return "\377\377\377\377" for 536870911' do
      @method.call(536870911).should == "\377\377\377\377"
    end
        
  end #calculate_integer_U29 method
  
  describe "writeU29 method" do 
    
    before(:each) do
      @method = @writer.method(:writeU29)
    end
    
    after(:each) {@method.call(2,@stream)}
    
    it 'should call calculate_integer_U29 when number is not cached' do
      @writer.should_receive(:calculate_integer_U29).with(2)
    end
    
    it 'should not call calculate_integer_U29 when number is cached' do
      @writer.instance_variable_get("@U29_integer_mappings")[2] = 0x02
      @writer.should_not_receive(:calculate_integer_U29)
    end
    
    it 'should write result to stream when number is cached' do
      @writer.instance_variable_get("@U29_integer_mappings")[2] = 0x02
      @stream.should_receive(:write).with(0x02)
    end
    
    it 'should write result to stream when number is not cached' do
      @writer.stub!(:calculate_integer_U29).and_return(1)
      @stream.should_receive(:write).with(1)
    end
  end #writeU29 method
  
  describe "write_with_reference_check method" do
    before(:each) do
      @method = @writer.method(:write_with_reference_check)
      @object =  [:some, :object]
      @block = lambda {}
    end
    
    after(:each) {@method.call(:object, @object, @stream, &@block)}
    
    it 'should look for the object in the reference table' do
      @writer.should_receive(:retrive).with(:object, @object)
    end
    
    it 'should call the block when the object is not found in the table' do
      @writer.stub!(:retrive).and_return(nil)
      @block = lambda {been_here}
      self.should_receive(:been_here)
    end
    
    it 'should store the object in the reference table when it was not found' do
      @writer.stub!(:retrive).and_return(nil)
      @writer.should_receive(:store)
    end
    
    it 'should write the reference index when object is found in the table' do
      @writer.stub!(:retrive).and_return(5)
      @writer.should_receive(:writeU29).with(5<<1, @stream)
    end
    
    it 'should not store the object when it is found in the reference table' do
      @writer.stub!(:retrive).and_return(5)
      @writer.stub!(:writeU29)
      @writer.should_not_receive(:store)
    end
  end #write_with_reference_check method
  
  describe "write_utf8_vr method" do
    before(:each) do
      @method = @writer.method(:write_utf8_vr)
      @string = "string"
    end
    
    after(:each) {@method.call(@string,@stream) }
    
    it 'should write the empty string without reference' do
      @string = ""
      @writer.should_receive(:writeU29).with(0x01,@stream)
      @writer.should_not_receive(:retrive)
    end
    
    it 'should look for the string in the reference table' do
      matcher = Spec::Matchers::SimpleMatcher.new(":string") {|act| act==:string}
      @writer.should_receive(:retrive).with(matcher, @string)
      @writer.stub!(:writeU29)
    end
    
    it 'should write the string when it was not found in the reference table' do
      @writer.stub!(:retrive)
      @writer.should_receive(:writeU29).with(13, @stream)
      @stream.should_receive(:write).with(@string)
    end
    
    it 'should write the reference when the string was found in the table' do
      @writer.stub!(:retrive).and_return(15)
      @writer.should_receive(:writeU29).with(15<<1, @stream)
      @stream.should_not_receive(:write)
    end
  end #write_utf8_vr method
  
  describe "write_array_type method" do
    before(:each) do
      @method = @writer.method(:write_array_type)
      @array = ["my", "array"]
    end
    
    after(:each) {@method.call(@array,@stream) }
    
    it 'should look for the array in the object reference table' do
      @writer.should_receive(:write_with_reference_check).with(:object, @array, @stream)
    end
    
    it 'should call writeU29A_value when array is not in the reference table' do
      @writer.stub!(:retrive)
      @writer.should_receive(:writeU29A_value).with(@array, @stream)
    end
  end #write_array_type method
  
  describe "writeU29A_value method" do
    before(:each) do
      @method = @writer.method(:writeU29A_value)
      @array = ["my", "array"]
    end
    
    after(:each) {@method.call(@array,@stream) }
    
    it 'should write the array length' do
      @writer.should_receive(:writeU29).with((2<<1)|1, @stream).once
      @array.stub!(:each)
    end
    
    it 'should write the empty string marker' do
      @writer.stub!(:writeU29)
      @stream.should_receive(:write).with("\001")
      @array.stub!(:each)
    end
    
    it 'should write the array contents' do
      @writer.should_receive(:write_value_type).with(@array[0], @stream)
      @writer.should_receive(:write_value_type).with(@array[1], @stream)
    end
  end #writeU29A_value method
  
  describe "writeU29O method" do
    before(:each) do
      @method = @writer.method(:writeU29O)
      @object = {}
    end
    
    after(:each) {@method.call(@object,@stream) }
    
    it 'should look for the object in the reference table' do
      @writer.should_receive(:write_with_reference_check).with(:object, @object, @stream)
    end
    
    it 'should look for the class in the reference table when object was not found' do
      @writer.should_receive(:retrive).with(:object, @object)
      @writer.should_receive(:retrive).with(:class, @object.class)
    end
    
    it 'should call writeU29O_object_traits when class is not found in reference table' do
      @writer.should_receive(:writeU29O_object_traits).with(@object,@stream)
    end
    
    it 'should not call writeU29O_object_traits when class is in the reference table' do
      @writer.store :class, @object.class
      @writer.should_not_receive(:writeU29O_object_traits).with(@object,@stream)
    end
    
    it 'should call writeU29O_object_members when object is not found in the reference table' do
      @writer.should_receive(:writeU29O_object_members).with(@object,@stream)
    end
    
    it 'should call writeU29O_object_dynamic_members when object is not found in the reference table' do
      @writer.should_receive(:writeU29O_object_dynamic_members).with(@object,@stream)
    end
  end #writeU29O method
  
  describe "writeU29O_object_members method" do
    before(:each) do
      @method = @writer.method(:writeU29O_object_members)
      @object = {}
      @object.class.flex_remoting.stub!(:members).and_return([:member1, :member2])
    end
    
    after(:each) {@method.call(@object,@stream) }
    
    it 'should fetch members from the class' do
      @object.class.flex_remoting.should_receive(:members).with(:default).and_return([])
    end
    
    it 'should write each member using the members reader defined for that class' do
      [:member1, :member2].each do |member|
        @object.class.flex_remoting.members_reader.should_receive(:call).with(@object,member)
      end
    end
  end #writeU29O_object_members method
  
  describe "writeU29O_object_dynamic_members method" do
    before(:each) do
      @method = @writer.method(:writeU29O_object_dynamic_members)
      @object = {}
      @object.class.flex_remoting.stub!(:dynamic_members).and_return({:member1=>1, :member2=>2})
    end
    
    after(:each) {@method.call(@object,@stream) }
    
    it 'should fetch dynamic members from the object' do
      @object.class.flex_remoting.should_receive(:dynamic_members).with(@object, :default).and_return([])
    end
    
    it 'should write each dynamic member and the empty marker' do
      {:member1=>1, :member2=>2}.each do |member_name, member_value|
        @writer.should_receive(:write_utf8_vr).with(member_name.to_s, @stream)
        @writer.should_receive(:write_value_type).with(member_value, @stream)
      end
      @writer.should_receive(:write_utf8_vr).with("", @stream)
    end
    
  end #writeU29O_object_dynamic_members method
  
  describe "writeU29O_object_traits method" do
    before(:each) do
      @method = @writer.method(:writeU29O_object_traits)
      @object = {}
      @object.class.flex_remoting.stub!(:members).and_return([:member1, :member2])
    end
    
    after(:each) {@method.call(@object,@stream)}
    
    it 'should write the member count with the dynamic object mask' do
      @object.class.flex_remoting.stub!(:is_dynamic).and_return(true)
      @writer.stub!(:write_utf8_vr)
      @writer.should_receive(:writeU29).with((2 << 4) | 0x0B, @stream)
    end
    
    it 'should write the member count with the non dynamic object mask' do
      @object.class.flex_remoting.stub!(:is_dynamic).and_return(false)
      @writer.stub!(:write_utf8_vr)
      @writer.should_receive(:writeU29).with((2 << 4) | 0x03, @stream)
    end
    
    it 'should write the class name' do
      @object.class.flex_remoting.stub!(:name).and_return("className")
      @object.class.flex_remoting.members.stub!(:each)
      @writer.should_receive(:write_utf8_vr).with("className", @stream)
    end
    
    it 'should write all the member names' do
      @writer.should_receive(:write_utf8_vr).with(@object.class.flex_remoting.name, @stream)
      [:member1, :member2].each do |m|
        @writer.should_receive(:write_utf8_vr).with(m.to_s, @stream)
      end
    end
  end #writeU29O_object_traits method
  
  describe "writeU29D method" do
    before(:each) do
      @method = @writer.method(:writeU29D)
      @date = Time.now
    end
    
    after(:each) {@method.call(@date,@stream)}
    
    it 'should call write_with_reference_check' do
      @writer.should_receive(:write_with_reference_check).with(:object, @date, @stream)
    end
    
    it 'should call writeU29D_value when date is not found in reference table' do
      @writer.should_receive(:writeU29D_value).with(@date, @stream)
    end
  end #writeU29D method
  
  describe "writeU29D_value method" do
    before(:each) do
      @method = @writer.method(:writeU29D_value)
      @date = Time.now
    end
    
    after(:each) {@method.call(@date,@stream)}
    
    it 'should write 1' do
      @writer.should_receive(:writeU29).with(1, @stream)
    end
    
    it 'should convert time to utc when it is a Time object' do
      @date.utc.should_receive(:to_i)
    end
    
    it 'should extract time with strftime when it is a Date object' do
      @date = Date.new
      @date.should_receive(:strftime).with("%s")
    end
    
    it 'should write the time as double with Time object' do
      @writer.should_receive(:write_double).with(@date.utc.to_i* 1000, @stream)
    end
    
    it 'should write the time as double with Date object' do
      @date = Date.today
      @writer.should_receive(:write_double).with(@date.strftime("%s").to_i* 1000, @stream)
    end
  end #writeU29D_value method
  
  describe "writeU29X method" do
    before(:each) do
      @method = @writer.method(:writeU29X)
      @xml = REXML::Document.new("")
    end
    
    after(:each) {@method.call(@xml, @stream)}
    
    it 'should call write_with_reference_check' do
      @writer.should_receive(:write_with_reference_check)
    end
    
    it 'should call writeU29X_value when xml is not found in reference table' do
      @writer.should_receive(:writeU29X_value).with(@xml, @stream)
    end
  end #writeU29X method
  
  describe "writeU29X_value method" do
    before(:each) do
      @method = @writer.method(:writeU29X_value)
      @xml = REXML::Document.new("<xml><some_tag></some_tag></xml>")
    end
    
    after(:each) {@method.call(@xml, @stream)}
    
    it 'should write xml length to stream' do
      @writer.should_receive(:writeU29).with(45, @stream)
    end
    
    it 'should write the xml as string' do
      @writer.stub!(:writeU29)
      @stream.should_receive(:write).with(@xml.to_s)
    end
  end #writeU29X_value method
  
  describe "writeU29B method" do
    before(:each) do
      @method = @writer.method(:writeU29B)
      @io = StringIO.new("SomeByteArray...")
    end
    
    after(:each) {@method.call(@io, @stream)}
    
    it 'should call write_with_reference_check' do
      @writer.should_receive(:write_with_reference_check).with(:object, @io, @stream)
    end
    
    it 'should call writeU29B_value when io is not found in reference table' do
      @writer.should_receive(:writeU29B_value).with(@io, @stream)
    end
  end #writeU29B method
  
  describe "writeU29B_value method" do
    before(:each) do
      @method = @writer.method(:writeU29B_value)
      @io = StringIO.new("SomeByteArray...")
    end
    
    after(:each) {@method.call(@io, @stream)}
    
    it 'should write the io length' do
      @writer.should_receive(:writeU29).with((@io.length << 1) | 1, @stream)
    end
  end #writeU29B_value method
end