require 'json'
require 'yaml'
require 'savon'

def get_file(file)
  [File.expand_path(File.dirname(__FILE__)), '/', file].join
end

def get_target
  target_file = get_file('target.json')
  target_data = open(target_file) { |f| JSON.load(f) }

  ret = target_data.inject([]) do |arr, (obj, fields)|
    arr << fields.map {|field| "#{obj}.#{field}" }
  end

  ret.flatten!
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
  metadata_url = response.body[:login_response][:result][:metadata_server_url]

  return session_id, metadata_url
end

def delete_fields(session_id, url, target)
  metadata_url = get_file('../wsdl/metadata.wsdl')
  client = Savon.client(
    :wsdl => metadata_url,
    :endpoint => url,
    :soap_header => {"tns:SessionHeader" => {"tns:sessionId" => session_id}}
  )

  target.each_slice(3) do |part|
    response = client.call(
      :delete_metadata,
      :message => {
        :type => 'CustomField',
        :fullnames => part
      }
    )

    puts response.body[:delete_metadata_response][:result]
  end
end

# get dasta
target_data = get_target
username, password, endpoint = get_config

# confirm
puts '--------------------------------------------------------------------'
puts format('username: %s', username)
puts '---------------------'
puts 'target:'
target_data.each { |target| puts format('    %s', target) }
puts '--------------------------------------------------------------------'
print 'are you sure?(y, n) > '
do_this = gets.chomp

exit(0) if 'y' != do_this

# access to salseforce
session_id, url = get_connection(username, password, endpoint)
delete_fields(session_id, url, target_data)

