require File.join(File.dirname(__FILE__),'../spec_helper')

describe RAMF::ReferenceTable do
  include RAMF::ReferenceTableUser
  
  before(:each) do
    register_reference_table
  end
  
  it 'should register the reference table' do
    @reference_table.should be_an_instance_of(RAMF::ReferenceTable)
  end
  
  it 'should store and retrive strings' do
    store :string, "Some String"
    retrive(:string, "Some String").should be(0)
  end
  
  it 'should store and retrive strings in the right order' do
    store :string, "First String"
    store :string, "Second String"
    retrive(:string, "First String").should be(0)
    retrive(:string, "Second String").should be(1)
  end
  
  it 'should retrive objects in the right order(with blocks)' do
    @object1 = Object.new
    @object2 = Object.new
    store :object do
      store :object do
        @object2
      end
      @object1
    end
    retrive(:object,0).should be(@object1)
    retrive(:object,1).should be(@object2)
  end
end