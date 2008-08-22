module RAMF
  module FlexObjects
    class AcknowledgeMessage < FlexObject
      
      def initialize(options={})
        super("flex.messaging.messages.AcknowledgeMessage".to_sym)
        self[:messageId] = rand_uuid
        self[:clientId] = options[:clientId] ||rand_uuid
        self[:destination] = nil
        self[:body] = options[:body] || nil
        self[:timeToLive] = 0
        self[:timestamp] = (String(Time.new) + '00')
        self[:headers] = {}
        self[:correlationId] = options[:message_id]
      end
      
      #going for speed with these UUID's not neccessarily unique in space and time continue - um, word
      def rand_uuid
        [8,4,4,4,12].map {|n| rand_hex_3(n)}.join('-').to_s
      end
      
      def rand_hex_3(l)
        "%0#{l}x" % rand(1 << l*4)
      end
      
    end    
  end
end
