module RAMF
  class ReferenceTable
    
    def initialize
      @object_references = {}
      @class_references = {}
      @string_references = {}
    end
    
    def store(group,fixed_key = nil, &block)
      raise "must give a block or a fixed_key to store" unless block_given? || fixed_key
      var_name = "@#{group.to_s}_references"
      reference_table = instance_variable_get(var_name)
      current_index = reference_table.length
      key = fixed_key ? fixed_key : current_index
      #TODO: change this to a real PlaceHolder class:
      reference_table[key] = PlaceHolder.new #put a stub place holder in case we need it 
      reference_table[key] = fixed_key ? current_index : block.call
    end
    
    def retrive(group, key)
      var_name = "@#{group.to_s}_references"
      reference_table = instance_variable_get(var_name)
      reference_table[key]
    end
  end
  
  module ReferenceTableUser
    
    def register_reference_table(reference_table)
      @reference_table = reference_table
    end
    
    def store(*args, &block)
      @reference_table.store(*args, &block)
    end
    
    def retrive(*args, &block)
      @reference_table.retrive(*args, &block)
    end
  end
end
    