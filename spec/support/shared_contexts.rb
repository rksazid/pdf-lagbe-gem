# frozen_string_literal: true

RSpec.shared_context 'with stubbed connection' do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:client) do
    PdfLagbe::Client.new(faraday_adapter: [:test, stubs])
  end

  after do
    stubs.verify_stubbed_calls
  end
end
