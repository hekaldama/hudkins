class Hapi
  # common methods available for all classes
  module Common

    # hide instance variables
    def inspect( string = nil )
      new_string = " " << string if string
      "#<%s:0x%x%s>" % [self.class, (self.object_id << 1), new_string]
    end

    ##
    # === Description
    # useful for escaping parameters to be sent to #get/#post
    #
    # === Parameters
    # +Hash+::  converts a simple one dimentional hash to a url parameter
    #           query string and uri escapes it.
    # +else+::  converts to string and uri escapes it.
    def url_escape msg
      case msg
      when Hash then
        URI.escape( msg.map {|k,v| "#{k}=#{v}" }.join("&") )
      else
        URI.escape( msg.to_s )
      end
    end

    # these classes are being included in the @hapi class.

    ##
    # accessor methods for child classes to get
    def get *args
      @hapi.get *args
    end

    ##
    # accessor methods for child classes to post
    def post *args
      @hapi.post *args
    end

    ##
    # TODO host is not universally accessible so this method might not belong here..
    # === Notes
    # My Hudson server is not publicially accessible so when I can't connect,
    # Socket#getaddrinfo (RestClient) times out after more than 20 seconds! I
    # created a healper class Hapi::HostLookup to timeout Socket#getaddrinfo
    # after Hapi::HostLookup#TIMEOUT seconds (defaults to 2).
    def host_available?
      HostLookup.available? @host, @options[:host_timeout]
    end

    ##
    # TODO host is not universally accessible so this method might not belong here..
    # Raise TimeoutError unless hudson host is responding within specified number of seconds.
    def check_host_availability
      # host is URI.
      msg = "`%s' did not respond within the set number of seconds." % [ host.host ]
      raise TimeoutError, msg unless host_available?
    end

  end
end
