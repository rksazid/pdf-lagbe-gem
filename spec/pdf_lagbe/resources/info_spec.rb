# frozen_string_literal: true

RSpec.describe PdfLagbe::Resources::Info do
  include_context 'with stubbed connection'

  describe '#fetch' do
    it 'returns parsed service info' do
      info_response = { service: 'pdf-lagbe', version: '1.0.0' }.to_json
      stubs.get('/') { [200, { 'content-type' => 'application/json' }, info_response] }

      result = client.info.fetch

      expect(result).to be_a(Hash)
      expect(result[:service]).to eq('pdf-lagbe')
      expect(result[:version]).to eq('1.0.0')
    end
  end
end
