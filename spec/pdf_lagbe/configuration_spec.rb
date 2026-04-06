# frozen_string_literal: true

RSpec.describe PdfLagbe::Configuration do
  subject(:config) { described_class.new }

  describe 'defaults' do
    it 'has the default base_url' do
      expect(config.base_url).to eq('https://pdf-lagbe.vercel.app')
    end

    it 'has the default open_timeout' do
      expect(config.open_timeout).to eq(10)
    end

    it 'has the default read_timeout' do
      expect(config.read_timeout).to eq(30)
    end

    it 'has the default write_timeout' do
      expect(config.write_timeout).to eq(30)
    end

    it 'has the default max_retries' do
      expect(config.max_retries).to eq(2)
    end

    it 'has the default retry_interval' do
      expect(config.retry_interval).to eq(1.0)
    end

    it 'has nil logger by default' do
      expect(config.logger).to be_nil
    end

    it 'has a user_agent with version' do
      expect(config.user_agent).to eq("PdfLagbe Ruby/#{PdfLagbe::VERSION}")
    end

    it 'has nil proxy by default' do
      expect(config.proxy).to be_nil
    end
  end

  describe '#to_h' do
    it 'returns a hash of all configuration values' do
      hash = config.to_h

      expect(hash).to include(
        base_url: 'https://pdf-lagbe.vercel.app',
        open_timeout: 10,
        read_timeout: 30
      )
    end
  end

  describe 'setters' do
    it 'allows setting base_url' do
      config.base_url = 'https://custom.example.com'
      expect(config.base_url).to eq('https://custom.example.com')
    end

    it 'allows setting timeouts' do
      config.open_timeout = 5
      config.read_timeout = 60
      config.write_timeout = 45

      expect(config.open_timeout).to eq(5)
      expect(config.read_timeout).to eq(60)
      expect(config.write_timeout).to eq(45)
    end
  end
end
