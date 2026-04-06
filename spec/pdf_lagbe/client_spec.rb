# frozen_string_literal: true

RSpec.describe PdfLagbe::Client do
  describe '#initialize' do
    it 'uses global configuration by default' do
      client = described_class.new
      expect(client.config).to be(PdfLagbe.configuration)
    end

    it 'accepts per-instance options' do
      client = described_class.new(base_url: 'https://custom.example.com', read_timeout: 60)

      expect(client.config.base_url).to eq('https://custom.example.com')
      expect(client.config.read_timeout).to eq(60)
    end

    it 'does not modify the global configuration' do
      described_class.new(base_url: 'https://custom.example.com')
      expect(PdfLagbe.configuration.base_url).to eq(PdfLagbe::Configuration::DEFAULT_BASE_URL)
    end
  end

  describe '#html_to_pdf' do
    it 'returns an HtmlToPdf resource' do
      client = described_class.new
      expect(client.html_to_pdf).to be_a(PdfLagbe::Resources::HtmlToPdf)
    end

    it 'memoizes the resource' do
      client = described_class.new
      expect(client.html_to_pdf).to be(client.html_to_pdf)
    end
  end

  describe '#health' do
    it 'returns a Health resource' do
      client = described_class.new
      expect(client.health).to be_a(PdfLagbe::Resources::Health)
    end
  end

  describe '#info' do
    it 'returns an Info resource' do
      client = described_class.new
      expect(client.info).to be_a(PdfLagbe::Resources::Info)
    end
  end
end
