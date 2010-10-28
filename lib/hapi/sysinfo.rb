

def find_svn_url host_name
  url = "http://example.com/_priv/sysinfo"
  uri = URI.parse url
  uri.host = host_name
  body = RestClient.get uri.to_s
  # is there a better way to do this? Rservices and Syndication differ in where
  # they put this info
  svn_url = body.scan(/repository":"([^ ]*) r\d*",/).first
end
