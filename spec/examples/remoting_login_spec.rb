require File.join(File.dirname(__FILE__),'../spec_helper')
require File.join(File.dirname(__FILE__),'examples_helper')
include RAMF
include ExampleHelper

describe "RAMF" do
  
  describe "remoting_login" do
    before(:all) do
      work_with_example(:remoting_login_operation) do |f|
        @deserializer = Deserializer::Base.new(f)
        @incoming_amf_object = @deserializer.process
        OperationProcessorsManager.add_operation_processor(ExampleHelper::OperationProcessor)
      end
      end
      
      describe "incoming_amf_object" do
        incoming_amf_object_examples
        
        describe "message" do
          before(:all) { @message = @incoming_amf_object.messages.first}
          incoming_amf_object_message_examples(:response_uri=>"/1", :length=>251,:target_uri=>"null")
          
          describe "value" do
            before(:all) {@value = @message.value.first}
            incoming_amf_object_message_value_examples(:class=>FlexObjects::CommandMessage,
                                                       :headers=>{:DSId=>"nil", :DSMessagingVersion=>1},
                                                       :messageId=>"231F8134-8454-9184-252F-F6ED9FF51A01",
                                                       :body=>"bXlVc2VybmFtZTpteVBhc3N3b3Jk",
                                                       :destination=>"",
                                                       :operation=>8)
            
          end #RAMF remoting_login incoming_amf_object message value
        end #RAMF remoting_login incoming_amf_object message
        
        describe "processed_incoming_amf_object" do
          before(:all) {@processed_incoming_amf_object = @incoming_amf_object.process}
          processed_incoming_amf_object_examples
          
          describe "message" do
            before(:all) {@message = @processed_incoming_amf_object.messages.first}
            processed_incoming_amf_object_message_examples(:target_uri=>"/1/onResult")
            
            describe "value" do
              before(:all) {@value = @message.value}
              processed_incoming_amf_object_message_value_examples(:body=>"Logging in with credentials {:password=>\"myPassword\", :userid=>\"myUsername\"}",
                                                                   :correlationId=>"231F8134-8454-9184-252F-F6ED9FF51A01")
            end
          end #RAMF remoting_login incoming_amf_object processed_incoming_amf_object message
        end #RAMF remoting_login incoming_amf_object processed_incoming_amf_object
      end #RAMF remoting_login incoming_amf_object
  end #RAMF remoting_login
end #RAMF
