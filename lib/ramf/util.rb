class RAMF::Util
  class << self
    
    def underscore(camel_cased_word)
       camel_cased_word.to_s.gsub(/::/, '/').
         gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
         gsub(/([a-z\d])([A-Z])/,'\1_\2').
         tr("-", "_").
         downcase
    end
    
    def method_name(uri)
       underscore(uri[rindex_or_value(uri,".",0)..-1])
    end
    
    def service_name(uri)
      to_ruby_namespace(uri.to_s[0..rindex_or_value(uri,".",uri.length)])
    end
    
    def to_ruby_namespace(str)
      str.split(".").each{|s| s[0..0] = s[0..0].upcase}.join("::")
    end
    
    def extract_credentials(base64)
      auth = Base64.decode64(base64).split(':',2)
      auth.empty? ? nil : {:userid => auth[0], :password => auth[1]}
    end
    
    def rindex_or_value(uri, sperator, value)
      uri.rindex(sperator) || value
    end
     
  end
end