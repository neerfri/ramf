require 'rubygems'
require 'spec'
require 'yaml'

unless defined?(RAMF_SPEC_HELPER)
  RAMF_SPEC_HELPER = true
  AMF_EXAMPLE_DIR = File.join(File.dirname(__FILE__), "fixtures")
  AMF_EXAMPLE_FILES = YAML.load_file(File.join(AMF_EXAMPLE_DIR, "catalog.yml"))
  
  
  if !defined?(RAMF_DEBUG)
    RAMF_DEBUG = true
  end
  
  class SpecOperationProcessor
    def self.will_process?(operation)
      true
    end
    
    def self.process(operation)
      #this is used to check the existence of credentials
      hello = operation.credentials[:userid] ? "Hello, #{operation.credentials[:userid]}, " : ""
      #this is to check other operation parameters
      hello << "#{operation.service}.#{operation.method} says hi with args: #{operation.args.inspect}"
    end
  end
  
  def work_with_example(example_name, &block)
    File.open(File.join(AMF_EXAMPLE_DIR, AMF_EXAMPLE_FILES[example_name])) do |file|
      block.call(file)
    end
  end
  
  require 'lib/ramf'
  
end

#Spec::Runner.configure do |config|
#end
#
#Spec::Example::Configuration