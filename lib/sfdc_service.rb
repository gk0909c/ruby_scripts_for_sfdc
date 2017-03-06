require 'httpclient'
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
    response = login_to_salesforce(config)
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

  def print_sobject_metadata(sobject)
    http_client = HTTPClient.new
    res = http_client.get_content(
      [@server_instance, '/services/data/v38.0/sobjects/', sobject].join,
      nil,
      Authorization: ['Bearer ', @session_id].join
    )

    body = JSON.parse(res)
    puts body
  end

  def create_nested_record(sobject, nested_record)
    http_client = HTTPClient.new
    res = http_client.post_content(
      [@server_instance, '/services/data/v38.0/composite/tree/', sobject, '/'].join,
      # [@server_instance, '/services/data/v38.0/sobjects/', sobject, '/'].join,
      nested_record,
      rest_header
    )

    puts res
  end

  private

    def login_to_salesforce(config)
      wsdl = get_file('lib/partner.wsdl')
      client = Savon.client(wsdl: wsdl, endpoint: config['endpoint'])
      client.call(
        :login,
        message: {
          username: config['username'],
          password: "#{config['password']}#{config['security_token']}"
        }
      )
    end

    def keep_connection_info(username, res)
      @username = username
      @session_id = res[:session_id]
      @server_url = res[:server_url]
      @metadata_url = res[:metadata_server_url]
      gen_server_instance
    end

    def gen_server_instance
      urls = @server_url.split('/')
      @server_instance = [urls[0], '//', urls[2]].join
    end

    def rest_header
      {
        Authorization: ['Bearer ', @session_id].join,
        'Content-Type' => 'application/json'
      }
    end
end
