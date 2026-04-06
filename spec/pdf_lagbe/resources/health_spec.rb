# frozen_string_literal: true

RSpec.describe PdfLagbe::Resources::Health do
  include_context 'with stubbed connection'

  describe '#check' do
    it 'returns parsed health data' do
      health_response = { status: 'idle', uptime: 12_345 }.to_json
      stubs.get('/health') { [200, { 'content-type' => 'application/json' }, health_response] }

      result = client.health.check

      expect(result).to be_a(Hash)
      expect(result[:status]).to eq('idle')
      expect(result[:uptime]).to eq(12_345)
    end
  end
end
