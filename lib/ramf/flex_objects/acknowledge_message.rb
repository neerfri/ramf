module RAMF
  module FlexObjects
    class AcknowledgeMessage
      flex_alias 'flex.messaging.messages.AcknowledgeMessage'
      MEMBERS = [:messageId, :clientId, :destination, :body, :timeToLive, :timestamp, :headers, :correlationId]
      
      flex_remoting_members MEMBERS 
      
      def initialize(options={})
        @messageId = rand_uuid
        @clientId = options[:clientId] ||rand_uuid
        @destination = nil
        @body = options[:body] || nil
        @timeToLive = 0
        @timestamp = Time.now.to_i * 100
        @headers = {}
        @correlationId = options[:message_id]
      end
      
      def rand_uuid
        [8,4,4,4,12].map {|n| rand_hex_3(n)}.join('-').to_s
      end
      
      def rand_hex_3(l)
        "%0#{l}x" % rand(1 << l*4)
      end
      
    end    
  end
end
