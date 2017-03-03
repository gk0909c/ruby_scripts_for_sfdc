require 'spec_helper'
require 'sfdc_service'

describe 'SfdcConnection' do
  let(:client) { spy('Savon Client') }
  let(:response) { double('Savon Call Response') }
  let(:login_response) do
    {
      login_response: {
        result: {
          session_id: 'test_id',
          server_url: 'server.com',
          metadata_server_url: 'metadata.com'
        }
      }
    }
  end
  let(:connection) { SfdcConnection.new }

  before do
    expect(YAML).to receive(:load_file).and_return('username' => 'user1')
  end

  describe '#initialize' do
    subject { connection }

    before do
      expect(Savon).to receive(:client).and_return(client)
      expect(client).to receive(:call).and_return(response)
      expect(response).to receive(:body).and_return(login_response)
    end

    it 'is assgin connection info' do
      expect(subject.instance_variable_get(:@username)).to eq('user1')
      expect(subject.instance_variable_get(:@session_id)).to eq('test_id')
      expect(subject.instance_variable_get(:@server_url)).to eq('server.com')
      expect(subject.instance_variable_get(:@metadata_url)).to eq('metadata.com')
    end
  end

  describe '#create_partner_client' do
    subject { connection.create_partner_client }

    before do
      expect(Savon).to receive(:client).and_return(client).twice
    end

    it 'create Savon Client' do
      expect(subject).to eq(client)
    end
  end

  describe '#create_metadata_client' do
    subject { connection.create_metadata_client }

    before do
      expect(Savon).to receive(:client).and_return(client).twice
    end

    it 'create Savon Client' do
      expect(subject).to eq(client)
    end
  end
end
