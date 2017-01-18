require './service/sfdc_service.rb'

connection = SfdcConnection.new
client = connection.create_partner_client

response = client.call(
  :describe_global
)
sobjects = response.body[:describe_global_response][:result][:sobjects]
sobjects
  .select { |object| object[:custom] }
  .each { |object| puts "name: #{object[:name].ljust(20)} label: #{object[:label]}" }

