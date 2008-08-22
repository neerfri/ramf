require File.join(File.dirname(__FILE__),'spec_helper')
AMF_EXAMPLE_DIR = File.join(File.dirname(__FILE__),'example_amf_messages')

describe RAMF::Deserializer do
  
  describe RAMF::Deserializer::Base do
    1.upto(2) do |i|
      File.open(File.join(AMF_EXAMPLE_DIR,"deserializer#{i}.rb"),"r") {|f| eval(f.read)}
    end
    
    it 'should return an RAMF::AMFObject after process' do
      deserialize_from_file('deserializer1.bin').should be_an_instance_of(RAMF::AMFObject)
    end
    
  end
  
  def deserialize_from_file(filename)
    File.open(File.join(AMF_EXAMPLE_DIR,filename),'r') do |f|
      deserializer = RAMF::Deserializer::Base.new(f)
      deserializer.process
    end
  end
end