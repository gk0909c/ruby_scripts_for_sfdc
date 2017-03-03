require 'spec_helper'
require 'file'

describe 'FileService' do
  let(:root_path) { File.expand_path([File.dirname(__FILE__), '/../../'].join) }
  let(:filename) { 'test.txt' }

  describe '#get_file' do
    it 'is return full path' do
      expect(FileService.get_file(filename)).to eq([root_path, '/', filename].join)
    end
  end
end
