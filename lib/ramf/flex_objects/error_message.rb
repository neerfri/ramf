class RAMF::FlexObjects::ErrorMessage < RAMF::FlexObjects::AcknowledgeMessage
  flex_alias "flex.messaging.messages.ErrorMessage"
  flex_remoting_members :extendedData, :faultCode, :faultDetail, :faultString, :rootCause
                        
  attr_accessor :extendedData, :faultCode, :faultDetail, :faultString, :rootCause
  
  def initialize(options = {})
    super(options)
    self.extendedData = options[:exception]
    self.faultDetail = options[:exception].message if options[:exception]
    self.faultString = options[:exception].message if options[:exception]
  end
  
end