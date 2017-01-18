require './service/sfdc_service.rb'

connection = SfdcConnection.new

client = connection.create_metadata_client
res = client.call(
  :list_metadata,
  :message => {
    :queries => {
      :type => 'Layout',
    },
    :api_version => 38,
  }
)

res.body[:list_metadata_response][:result]
  .sort_by { |layout| layout[:full_name] }
  .each { |layout| puts "name: #{layout[:full_name]}" }

