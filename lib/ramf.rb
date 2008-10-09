
$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'stringio'
module RAMF; end;
  
#Load configuration class
require 'ramf/util'
require 'ramf/configuration'


#Extensions to existing Ruby classes.
require 'ramf/flex_class_traits'
require 'ramf/extensions/class'
require 'ramf/extensions/object'
require 'ramf/extensions/hash'
require 'ramf/extensions/exception'

#RAMF fundemental objects
require 'ramf/amf_object'
require 'ramf/amf_header'
require 'ramf/amf_message'
require 'ramf/operation_request'
require 'ramf/operation_processor'

require 'ramf/io/flex_class_signature'
require 'ramf/flex_objects/flex_anonymous_object'
require 'ramf/flex_objects/flex_object'
require 'ramf/flex_objects/acknowledge_message'
require 'ramf/flex_objects/remoting_message'
require 'ramf/flex_objects/command_message'
require 'ramf/flex_objects/byte_array'


require 'ramf/io/constants'
require 'ramf/io/common_read_write'
require 'ramf/io/place_holder'
require 'ramf/io/reference_table'
require 'ramf/deserializer'
require 'ramf/serializer'

module RAMF
  class NullLogger
    def debug(message); end;
  end
  
  def self.define_debug_logger
    begin
      puts "initializing RAMF debug log file"
      require 'fileutils'
      require 'logger'
      log_path = File.join(File.dirname(__FILE__),'../debug/debug.log')
      FileUtils.mkdir_p File.dirname(log_path)
      Logger.new(log_path)
    rescue Exception=>e
      NullLogger.new()
    end
  end
  
  DEBUG_LOG =  defined?(RAMF_DEBUG) || ENV["RAMF_DEBUG"] ? define_debug_logger : NullLogger.new()
end