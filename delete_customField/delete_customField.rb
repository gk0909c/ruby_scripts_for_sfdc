require './service/sfdc_service.rb'
require './service/file.rb'

def get_target
  target_file = FileService.get_file('../delete_customField/target.json')
  target_data = open(target_file) { |f| JSON.load(f) }

  ret = target_data.inject([]) do |arr, (obj, fields)|
    arr << fields.map {|field| "#{obj}.#{field}" }
  end

  ret.flatten!
end

# main script
target_data = get_target
connection = SfdcConnection.new

# confirm
puts '--------------------------------------------------------------------'
puts format('username: %s', connection.username)
puts '---------------------'
puts 'target:'
target_data.each { |target| puts format('    %s', target) }
puts '--------------------------------------------------------------------'
print 'are you sure?(y, n) > '
do_this = gets.chomp

exit(0) if 'y' != do_this

client = connection.create_metadata_client

# delete field per 10 count.
target_data.each_slice(10) do |target|
  response = client.call(
    :delete_metadata,
    :message => {
      :type => 'CustomField',
      :fullnames => target
    }
  )

  puts response.body[:delete_metadata_response][:result]
end
