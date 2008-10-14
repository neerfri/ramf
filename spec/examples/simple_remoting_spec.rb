require File.join(File.dirname(__FILE__),'../spec_helper')
require File.join(File.dirname(__FILE__),'examples_helper')
include RAMF
include ExampleHelper

describe "RAMF" do
  
  describe "simple_remoting_example" do
    before(:all) do
      work_with_example(:simple_remoting) do |f|
        @deserializer = Deserializer::Base.new(f)
        @incoming_amf_object = @deserializer.process
        OperationProcessorsManger.add_operation_processor(ExampleHelper::OperationProcessor)
      end
    end
    
      describe "incoming_amf_object" do
        incoming_amf_object_examples
        
        describe "message" do
          before(:all) { @message = @incoming_amf_object.messages.first}
          incoming_amf_object_message_examples(:response_uri=>"/2", :length=>237, :target_uri=>"null")
          
          describe "value" do
            before(:all) {@value = @message.value.first}
            incoming_amf_object_message_value_examples(:class=>FlexObjects::RemotingMessage,
                                                       :headers=>{:DSEndpoint=>"ramf", :DSId=>"nil"},
                                                       :messageId=>"91B3B766-DE81-122D-E7FA-E18B83359EE8",
                                                       :body=>["3"],
                                                       :destination=>"HomeController",
                                                       :operation=>"getList")
            it('should declare source nil') { @value.source.should == nil }
            
          end #RAMF simple_remoting_example incoming_amf_object message value
          
        end #RAMF simple_remoting_example incoming_amf_object message
        
        describe "processed_incoming_amf_object" do
          before(:all) {@processed_incoming_amf_object = @incoming_amf_object.process}
          processed_incoming_amf_object_examples
          
          describe "message" do
            before(:all) {@message = @processed_incoming_amf_object.messages.first}
            processed_incoming_amf_object_message_examples(:target_uri=>"/2/onResult")
            
            describe "value" do
              before(:all) {@value = @message.value}
              processed_incoming_amf_object_message_value_examples(:body=>"RemotingMessage: HomeController.get_list without credentials",
                                                                   :correlationId=>"91B3B766-DE81-122D-E7FA-E18B83359EE8")
            end
            
          end #RAMF simple_remoting_example incoming_amf_object processed_incoming_amf_object message
          
        end #RAMF simple_remoting_example incoming_amf_object processed_incoming_amf_object
        
      end #RAMF simple_remoting_example incoming_amf_object
      
  end #RAMF simple_remoting_example
  
end #RAMF