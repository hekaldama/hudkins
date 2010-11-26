class Hapi
  # common methods available for all classes
  module Common

    # hide instance variables
    def inspect( string = nil )
      new_string = " " << string if string
      "#<%s:0x%x%s>" % [self.class, (self.object_id << 1), new_string]
    end

    ##
    # useful for escaping parameters to be sent to #get/#post
    #
    # Examples:
    #   +Hash+::  converts a simple one dimentional hash to a url parameter
    #             query string and uri escapes it.
    #   +else+::  converts to string and uri escapes it.
    def url_escape msg
      case msg
      when Hash then
        URI.escape( msg.map {|k,v| "#{k}=#{v}" }.join("&") )
      else
        URI.escape( msg.to_s )
      end
    end

    def get *args
      @hapi.get *args
    end

    def post *args
      @hapi.post *args
    end

  end
end
