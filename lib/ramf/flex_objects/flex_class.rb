module RAMF
  module FlexObjects
    class FlexClass
      
      attr_reader :name, :is_dynamic, :members
      
      def initialize(name,is_dynamic)
        @name = name.empty? ? name : name.to_sym
        @is_dynamic = is_dynamic
        @members = []
      end
      
      def dynamic_members
        @dynamic_members||= self.instance_variables.inject(Hash.new) do |memo,var_name|
        puts "found instance variable: #{var_name} with value: #{self.instance_variable_get(var_name)}"
          memo[var_name[1..-1]] = self.instance_variable_get(var_name)
          memo
        end
      end
      
    end
  end
end
