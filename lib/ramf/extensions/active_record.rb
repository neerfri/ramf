module ActiveRecord
  class Base
    
    flex_remoting_transient :attributes,:attributes_cache
    
    class << self 
      def flex_members
        self.column_names.map{|v| v.to_sym}
      end
    end
  end
end