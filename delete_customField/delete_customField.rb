require 'json'
require 'savon'

def get_connection
  partner_wsdl = File.expand_path(File.dirname(__FILE__)) + '/../wsdl/partner.wsdl'
  client = Savon.client(wsdl: partner_wsdl)
  response = client.call(
    :login,
    :message => {
      :username => 'satohk@hrk.dev1.tv.co.jp',
      :password => 'satken0909'
    }
  )
  session_id = response.body[:login_response][:result][:session_id]
  metadata_url = response.body[:login_response][:result][:metadata_server_url]

  cli2 = Savon.client(
    wsdl: partner_wsdl,
    endpoint: response.body[:login_response][:result][:server_url],
    soap_header: {
      "tns:SessionHeader" => {"tns:sessionId" => session_id}
    }
  )

  res2 = cli2.call(:describe_s_objects)
  puts res2
end

get_connection

