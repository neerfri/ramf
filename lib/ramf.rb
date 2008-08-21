
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
  
require 'ramf/constants'
require 'ramf/amf_object'
require 'ramf/amf_header'
require 'ramf/amf_message'
require 'ramf/flex_objects'
require 'ramf/flex_class_traits'
require 'ramf/extensions/active_record'
require 'ramf/extensions/object'
require 'ramf/extensions/core_extensions'
require 'ramf/extensions/class'
require 'ramf/io/common_read_write'
require 'ramf/io/place_holder'
require 'ramf/io/reference_table'
require 'ramf/deserializer'
require 'ramf/serializer'

#Class.extend(FlexRemotingClassExtensions)
#module AMFSerializer
#  
#end