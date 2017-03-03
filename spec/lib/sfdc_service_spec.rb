require 'spec_helper'
require 'sfdc_service'

describe 'SfdcConnection' do
  let(:client) { double('Savon Client') }
  let(:response) { double('Savon Call Response') }

  before do
    config = { 'username' => 'user1' }
    expect(YAML).to receive(:load_file).and_return(config)
    expect(Savon).to receive(:client).and_return(client)
    expect(client).to receive(:call).and_return(response)
  end

  describe '#initialize' do
    subject { SfdcConnection.new }

    before do
      res = {
        login_response: {
          result: {
            session_id: 'test_id',
            server_url: 'server.com',
            metadata_server_url: 'metadata.com'
          }
        }
      }
      expect(response).to receive(:body).and_return(res)
    end

    it 'is assgin connection info' do
      expect(subject.instance_variable_get(:@username)).to eq('user1')
      expect(subject.instance_variable_get(:@session_id)).to eq('test_id')
      expect(subject.instance_variable_get(:@server_url)).to eq('server.com')
      expect(subject.instance_variable_get(:@metadata_url)).to eq('metadata.com')
    end
  end
end
