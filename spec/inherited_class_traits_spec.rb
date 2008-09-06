#this file checks the behavior of FlexClassTraits with inheritance
require File.join(File.dirname(__FILE__),'spec_helper')

class ParentClass
  flex_remoting_members :title, :body, :views_count
  flex_remoting_transient :trans1, :trans2
  flex_remoting_scope :reader, :only=>[:title, :body]
  flex_remoting_scope :critic, :except=>[:views_count]
end


class ChildClass < ParentClass
  flex_remoting_members :updates_count
  flex_remoting_transient :trans3, :trans4
  flex_remoting_scope :critic, :except=>[:updates_count]
end

describe ParentClass do
  
  it 'should have transient members :trans1 and :trans2' do
    ParentClass.flex_remoting.transient_members.should include(:trans1)
    ParentClass.flex_remoting.transient_members.should include(:trans2)
  end
  
  it 'should only render :title and :body when in scope :reader' do
    ParentClass.flex_remoting.amf_scope_options[:reader][:only].should == [:title, :body]
  end
  
  it 'should render everything except :views_count when in scope :critic' do
    ParentClass.flex_remoting.amf_scope_options[:critic][:except].should == [:views_count]
  end
  
  it 'should have members :title, :body and :views_count' do
    ParentClass.flex_remoting.members.should == [:title, :body, :views_count]
  end
end

describe ChildClass do
  
  it 'should have transient members :trans1, :trans2, :trans3 and :trans4' do
    ChildClass.flex_remoting.transient_members.should include(:trans1)
    ChildClass.flex_remoting.transient_members.should include(:trans2)
    ChildClass.flex_remoting.transient_members.should include(:trans3)
    ChildClass.flex_remoting.transient_members.should include(:trans4)
  end
  
  it 'should only render :title and :body when in scope :reader' do
    ChildClass.flex_remoting.amf_scope_options[:reader][:only].should == [:title, :body]
  end
  
  it 'should render everything except :updates_count when in scope :critic' do
    ChildClass.flex_remoting.amf_scope_options[:critic][:except].should == [:updates_count]
  end
  
  it 'should have members :title, :body, :views_count and :updates_count' do
    ChildClass.flex_remoting.members.should == [:title, :body, :views_count, :updates_count]
  end
end