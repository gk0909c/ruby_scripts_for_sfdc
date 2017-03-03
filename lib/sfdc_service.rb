require 'json'
require 'yaml'
require 'savon'
require './lib/file.rb'

# class for salesforce connection
class SfdcConnection
  include FileService

  attr_reader :username

  def initialize
    config = YAML.load_file(get_file('lib/sfdc.yaml'))

    client = create_client('partner.wsdl', config['endpoint'])
    response = client.call(
      :login,
      message: {
        username: config['username'],
        password: "#{config['password']}#{config['security_token']}"
      }
    )

    keep_connection_info(config['username'], response.body[:login_response][:result])
  end

  def create_partner_client
    wsdl = get_file('lib/partner.wsdl')
    Savon.client(
      wsdl: wsdl,
      endpoint: @server_url,
      soap_header: { 'tns:SessionHeader' => { 'tns:sessionId' => @session_id } }
    )
  end

  def create_metadata_client
    wsdl = get_file('lib/metadata.wsdl')
    Savon.client(
      wsdl: wsdl,
      endpoint: @metadata_url,
      soap_header: { 'tns:SessionHeader' => { 'tns:sessionId' => @session_id } }
    )
  end

  private

    def create_client(wsdl_file, endpoint)
      wsdl = get_file(wsdl_file)
      Savon.client(wsdl: wsdl, endpoint: endpoint)
    end

    def keep_connection_info(username, res)
      @username = username
      @session_id = res[:session_id]
      @server_url = res[:server_url]
      @metadata_url = res[:metadata_server_url]
    end
end
