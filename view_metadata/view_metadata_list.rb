require './service/sfdc_service.rb'

# recieve metadata type
print 'Specify metadata type > '
metadata_type = gets.chomp

# connect to salesforce
connection = SfdcConnection.new
client = connection.create_metadata_client
res = client.call(
  :list_metadata,
  message: {
    queries: {
      type: metadata_type
    },
    api_version: 38
  }
)

# print result
metadatas = res.body[:list_metadata_response][:result]
               .sort_by { |layout| layout[:full_name] }
puts '========================================================='
puts connection.username
puts '========================================================='
metadatas.each { |layout| puts layout[:full_name] }
puts '========================================================='
