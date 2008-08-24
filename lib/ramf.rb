
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

#Extensions to existing Ruby classes.
require 'ramf/flex_class_traits'
require 'ramf/extensions/class'
require 'ramf/extensions/object'
require 'ramf/extensions/active_record'

#RAMF fundemental objects
require 'ramf/amf_object'
require 'ramf/amf_header'
require 'ramf/amf_message'
require 'ramf/io/flex_class_signature'
require 'ramf/flex_objects/flex_anonymous_object'
require 'ramf/flex_objects/flex_object'
require 'ramf/flex_objects/acknowledge_message'
require 'ramf/io/constants'
require 'ramf/io/common_read_write'
require 'ramf/io/place_holder'
require 'ramf/io/reference_table'
require 'ramf/deserializer'
require 'ramf/serializer'

#Class.extend(FlexRemotingClassExtensions)
#module AMFSerializer
#  
#end