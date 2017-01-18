require 'json'
require 'yaml'
require 'savon'

# todo: common method
def get_file(file)
  [File.expand_path(File.dirname(__FILE__)), '/', file].join
end

def get_config
  config = YAML.load_file(get_file('sfdc.yaml'))
  return config['username'], "#{config['password']}#{config['security_token']}", config['endpoint']
end

def get_connection(username, password, endpoint)

  partner_wsdl = get_file('../wsdl/partner.wsdl')
  client = Savon.client(wsdl: partner_wsdl, :endpoint => endpoint)
  response = client.call(
    :login,
    :message => {
      :username => username,
      :password => password
    }
  )
  session_id = response.body[:login_response][:result][:session_id]
  server_url = response.body[:login_response][:result][:server_url]
  metadata_url = response.body[:login_response][:result][:metadata_server_url]

  return session_id, server_url, metadata_url
end

def view_custom_objects(session_id, url)
  partner_wsdl = get_file('../wsdl/partner.wsdl')
  client = Savon.client(
    :wsdl => partner_wsdl,
    :endpoint => url,
    :soap_header => {"tns:SessionHeader" => {"tns:sessionId" => session_id}}
  )

  response = client.call(
    :describe_global
  )

  sobjects = response.body[:describe_global_response][:result][:sobjects]
  sobjects.select { |object| object[:custom] }
    .each { |object| puts "name: #{object[:name].ljust(20)} label: #{object[:label]}" }
end

# get dasta
username, password, endpoint = get_config

# access to salseforce
# todo: this is to be proc?
session_id, server_url, _ = get_connection(username, password, endpoint)
view_custom_objects(session_id, server_url)

