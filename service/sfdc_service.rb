require 'json'
require 'yaml'
require 'savon'

class SfdcConnection
  def initialize
    config = YAML.load_file(get_file('sfdc.yaml'))

    client = create_client('partner.wsdl', config['endpoint'])
    response = client.call(
      :login,
      :message => {
        :username => config['username'],
        :password => "#{config['password']}#{config['security_token']}"
      }
    )
    @session_id = response.body[:login_response][:result][:session_id]
    @server_url = response.body[:login_response][:result][:server_url]
    @metadata_url = response.body[:login_response][:result][:metadata_server_url]
  end

  def create_partner_client
    wsdl = get_file('partner.wsdl')
    Savon.client(
      :wsdl => wsdl,
      :endpoint => @server_url,
      :soap_header => {"tns:SessionHeader" => {"tns:sessionId" => @session_id}}
    )
  end

  private
    def get_file(file)
      [File.expand_path(File.dirname(__FILE__)), '/', file].join
    end

    def create_client(wsdl_file, endpoint)
      wsdl = get_file(wsdl_file)
      Savon.client(wsdl: wsdl, :endpoint => endpoint)
    end
end
