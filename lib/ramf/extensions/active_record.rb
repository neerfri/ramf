module ActiveRecord
  class Base
    class << self 
      def flex_class_name
        self.name
      end
      
      def flex_members
        self.column_names.map{|v| v.to_sym}
      end
      
      def flex_dynamic?
        true
      end
      
      def flex_transient_members
        [:attributes,:attributes_cache]
      end
    end
  end
end