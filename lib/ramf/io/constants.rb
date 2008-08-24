module RAMF
  module IO
    module Constants
      #AMF0
      AMF0_NUMBER = 0x00
      AMF0_BOOLEAN = 0x01
      AMF0_STRING = 0x02
      AMF0_OBJECT = 0x03
      AMF0_MOVIE_CLIP = 0x04
      AMF0_NULL = 0x05
      AMF0_UNDEFINED = 0x06
      AMF0_REFERENCE = 0x07
      AMF0_MIXED_ARRAY = 0x08
      AMF0_EOO = 0x09
      AMF0_ARRAY = 0x0A
      AMF0_DATE = 0x0B
      AMF0_LONG_STRING = 0x0C
      AMF0_UNSUPPORTED = 0x0D
      AMF0_RECORDSET = 0x0E
      AMF0_XML = 0x0F
      AMF0_TYPED_OBJECT = 0x10
      
      #AMF0 MARKERS
      AMF0_NUMBER_MARKER = "\000"
      AMF0_BOOLEAN_MARKER = "\001"
      AMF0_STRING_MARKER = "\002"
      AMF0_OBJECT_MARKER = "\003"
      AMF0_MOVIE_CLIP_MARKER = "\004"
      AMF0_NULL_MARKER = "\005"
      AMF0_UNDEFINED_MARKER = "\006"
      AMF0_REFERENCE_MARKER = "\007"
      AMF0_ECMA_ARRAY_MARKER = "\010"
      AMF0_OBJECT_END_MARKER = "\011"
      AMF0_ARRAY_MARKER = "\012"
      AMF0_DATE_MARKER = "\013"
      AMF0_LONG_STRING_MARKER = "\014"
      AMF0_UNSUPPORTED_MARKER = "\015"
      AMF0_RECORDSET_MARKER = "\016"
      AMF0_XML_MARKER = "\017"
      AMF0_TYPED_OBJECT_MARKER = "\020"
    
      #AMF3
      AMF3_TYPE         = 0x11
      AMF3_UNDEFINED    = 0x00
      AMF3_NULL         = 0x01
      AMF3_FALSE        = 0x02
      AMF3_TRUE         = 0x03
      AMF3_INTEGER      = 0x04
      AMF3_DOUBLE       = 0x05
      AMF3_STRING       = 0x06
      AMF3_XML_DOC      = 0x07
      AMF3_DATE         = 0x08
      AMF3_ARRAY        = 0x09
      AMF3_OBJECT       = 0x0A
      AMF3_XML          = 0x0B
      AMF3_BYTE_ARRAY   = 0x0C
      AMF3_INTEGER_MAX  = 268435455
      AMF3_INTEGER_MIN  = -268435456
      
      #AMF3 Markers
      AMF3_TYPE_MARKER         = "\021"
      AMF3_UNDEFINED_MARKER    = "\000"
      AMF3_NULL_MARKER         = "\001"
      AMF3_FALSE_MARKER        = "\002"
      AMF3_TRUE_MARKER         = "\003"
      AMF3_INTEGER_MARKER      = "\004"
      AMF3_DOUBLE_MARKER       = "\005"
      AMF3_STRING_MARKER       = "\006"
      AMF3_XML_DOC_MARKER      = "\007"
      AMF3_DATE_MARKER         = "\010"
      AMF3_ARRAY_MARKER        = "\011"
      AMF3_OBJECT_MARKER       = "\012"
      AMF3_XML_STRING_MARKER   = "\013"
      AMF3_BYTE_ARRAY_MARKER   = "\014"
      
      AMF3_EMPTY_STRING = "\001"
    end
  end
end
