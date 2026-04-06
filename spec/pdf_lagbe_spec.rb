# frozen_string_literal: true

RSpec.describe PdfLagbe do
  describe '.configure' do
    it 'yields the configuration' do
      expect { |b| described_class.configure(&b) }
        .to yield_with_args(PdfLagbe::Configuration)
    end

    it 'sets configuration values' do
      described_class.configure do |config|
        config.base_url = 'https://example.com'
      end

      expect(described_class.configuration.base_url).to eq('https://example.com')
    end
  end

  describe '.client' do
    it 'returns a Client instance' do
      expect(described_class.client).to be_a(PdfLagbe::Client)
    end

    it 'memoizes the client' do
      expect(described_class.client).to be(described_class.client)
    end
  end

  describe '.reset!' do
    it 'resets configuration to defaults' do
      described_class.configure { |c| c.base_url = 'https://custom.com' }
      described_class.reset!

      expect(described_class.configuration.base_url)
        .to eq(PdfLagbe::Configuration::DEFAULT_BASE_URL)
    end

    it 'clears the memoized client' do
      old_client = described_class.client
      described_class.reset!

      expect(described_class.client).not_to be(old_client)
    end
  end

  it 'has a version number' do
    expect(PdfLagbe::VERSION).not_to be_nil
  end
end
