require 'rubygems'
require 'spec'
require 'yaml'

unless defined?(RAMF_SPEC_HELPER)
  RAMF_SPEC_HELPER = true
  AMF_EXAMPLE_DIR = File.join(File.dirname(__FILE__), "example_amf_messages")
  AMF_EXAMPLE_FILES = YAML.load_file(File.join(AMF_EXAMPLE_DIR, "catalog.yml"))
  
  
  if !defined?(RAMF_DEBUG)
    RAMF_DEBUG = true
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