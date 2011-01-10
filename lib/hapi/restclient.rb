class Hapi
  ##
  # === Description
  # Convenience class for RestClient responses
  #
  # RestClient.get returns (configurable via &block parameter to Hapi#get)
  # [#response, #request, #result]. I wanted to have all these available but
  # not as an array :/
  #
  # === Example
  #   # get response headers
  #   hud.get( "/path" ).response.headers
  #
  #   # do something based on response success
  #   response = hud.get "/path"
  #   raise response.message unless response.success?
  class Response
    attr_accessor :response, :request, :result
    ##
    # === Example
    # hud.get("/path") do |*args|
    #   Hapi::Response.new( *args )
    # end
    # # => returns Hapi::Response object
    def initialize response, request, result
      @response = response
      @request = request
      @result = result
    end

    ##
    # === Description
    # response = get "/path"
    # JSON.pasre response.body
    def body
      response.body
    end

    ##
    # === Description
    # response status code
    def code
      result.code.to_i
    end

    ##
    # === Description
    # RestClient response error
    def errors
      RestClient::Exceptions::EXCEPTIONS_MAP[response.code].new response
    end

    ##
    # === Description
    # #errors message
    def message
      errors.message
    end

    ##
    # === Description
    # was the response successful?
    # does a simple test if the response code was 2xx
    def success?
      # I think RestClient::Response doesn't use Net::HTTP... any more, but I
      # couldn't figure out how they want you to do this without doing case
      # format or something like RestClient::Ok.. etc. (There is no equivalent
      # RestClient::Success, although there is a RestClient::Redirect
      case result
      when Net::HTTPSuccess, Net::HTTPRedirection then
        true
      else
        false
      end
      #case code
      #when (200..299)
        #true
      #when (302) 
        ## Found. seems to be status code for successful posts.. :/
        #true
      #else
        #false
      #end
    end
    # http_body.match(/<h1>Error<\/h1><p>([^<]*)<\/p>/)[0]

    ##
    # Hudson returns type :javascript for get "/api/json" even if I explicietly set the :accept header
    # and :html for config.xml
    # so I'm going to use the request headers to get the returned content type... blah

    def response_type
      # unbelievable hudson!
      # this probably isn't the best way, but MIME::Types returns an array...
      MIME::Type.new request.headers[:accept]
    end

    def type
      response_type.sub_type.to_sym
    end
  end

  # the idea behind this is that if the hudson server isn't available,
  # getaddrinfo has a really long timeout.. like over 20 seconds! This is
  # really a DNS issue, but I still don't want to wait that long and I couldn't
  # figure out how to set a better timeout.
  module HostLookup
    # defaults to 2
    TIMEOUT = 2
    ##
    # timeout Socket.getaddrinfo after TIMEOUT seconds
    #
    # returns true/false
    def self.available? uri, timeout = nil
      timeout ||= TIMEOUT
      pid = fork do
        Socket.getaddrinfo( uri.host, uri.scheme )
      end
      begin
        Timeout::timeout(timeout) do 
          Process.wait(pid)
        end
        true
      rescue Timeout::Error
        Process.kill(9, pid)
        false
      end
    end
  end
end
