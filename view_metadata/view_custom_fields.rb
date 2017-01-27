require './service/sfdc_service.rb'

print 'Specify metadata type > '
custom_object = gets.chomp

connection = SfdcConnection.new
client = connection.create_partner_client

response = client.call(
  :describe_s_object,
  :message => {
    :s_object_type => custom_object
  }
)
fields = response.body[:describe_s_object_response][:result][:fields]
fields
  .each { |field| puts "name: #{field[:name].ljust(30)} label: #{field[:label]}" }

