
$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
module RAMF
  
  def self.relative_require(name)
    require File.join(File.dirname(__FILE__), name+".rb")
  end
  
  #load requirements from ruby
  require 'stringio'

  #Load configuration class
  relative_require 'ramf/util'
  relative_require 'ramf/configuration'
  
  
  #Extensions to existing Ruby classes.
  relative_require 'ramf/flex_class_traits'
  relative_require 'ramf/extensions/class'
  relative_require 'ramf/extensions/object'
  relative_require 'ramf/extensions/hash'
  relative_require 'ramf/extensions/exception'
  
  #RAMF fundemental objects
  relative_require 'ramf/amf_object'
  relative_require 'ramf/amf_header'
  relative_require 'ramf/amf_message'
  relative_require 'ramf/operation_request'
  relative_require 'ramf/operation_processors_manager'
  relative_require 'ramf/default_operation_processor'
  
  relative_require 'ramf/io/flex_class_signature'
  relative_require 'ramf/flex_objects/flex_anonymous_object'
  relative_require 'ramf/flex_objects/flex_object'
  relative_require 'ramf/flex_objects/acknowledge_message'
  relative_require 'ramf/flex_objects/error_message'
  relative_require 'ramf/flex_objects/remoting_message'
  relative_require 'ramf/flex_objects/command_message'
  relative_require 'ramf/flex_objects/byte_array'
  
  
  relative_require 'ramf/io/constants'
  relative_require 'ramf/io/common_read_write'
  relative_require 'ramf/io/place_holder'
  relative_require 'ramf/io/reference_table'
  relative_require 'ramf/deserializer'
  relative_require 'ramf/serializer'

end
  