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
       underscore(uri[uri.rindex(".")+1..-1])
    end
    
    def service_name(uri)
      uri[0..uri.rindex(".")].split(".").each{|s| s[0..0] = s[0..0].upcase}.join("::")
    end
     
  end
end