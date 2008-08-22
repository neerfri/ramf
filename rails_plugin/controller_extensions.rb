ActionController::Base.class_eval do
  attr_reader :render_amf
  def render_with_amf(options = nil, &block)
    begin
      if options && options.is_a?(Hash) && options.keys.include?(:amf)
        @render_amf = options[:amf]
        @amf_scope = options[:scope]
        @performed_render = true
      else
        render_without_amf(options,&block)
      end
    rescue Exception => e
      #suppress missing template warnings
      raise e if !e.message.match(/^Missing template/)
    end
  end
  alias_method_chain :render, :amf
end

class ActionController::Base
  
  attr_accessor :request_amf
  attr_accessor :rubyamf_params # this way they can always access the rubyamf_params
  
  #Higher level "credentials" method that returns credentials wether or not 
  #it was from setRemoteCredentials, or setCredentials  
  def credentials
    empty_auth = {:userid => nil, :password => nil}
    amf_credentials||html_credentials||empty_auth #return an empty auth, this watches out for being the cause of an exception, (nil[])
  end
  
  def is_amf
    request_amf ? true : false
  end
  
  
  private
  #setCredentials access
  def amf_credentials
    request_amf ? request_amf.get_header_by_key('Credentials').value : nil
  end
  
  def html_credentials
    auth_data = request.env['RAW_POST_DATA']
    auth_data = auth_data.scan(/DSRemoteCredentials.*?\001/)
    if auth_data.size > 0
      auth_data = auth_data[0][21, auth_data[0].length-22]
      remote_auth = Base64.decode64(auth_data).split(':')[0..1]
    else
      return nil
    end
    return {:userid => remote_auth[0], :password => remote_auth[1]}
  end
  
end