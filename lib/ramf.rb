
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
  
require 'ramf/constants'
require 'ramf/amf_object'
require 'ramf/amf_header'
require 'ramf/amf_message'
require 'ramf/flex_objects'
require 'ramf/io/common_read_write'
require 'ramf/io/place_holder'
require 'ramf/io/reference_table'
require 'ramf/deserializer'
require 'ramf/serializer'

require 'ramf/flex_class_traits'
require 'ramf/extensions/class'
require 'ramf/extensions/object'
require 'ramf/extensions/active_record'
#Class.extend(FlexRemotingClassExtensions)
#module AMFSerializer
#  
#end