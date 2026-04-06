# frozen_string_literal: true

RSpec.describe PdfLagbe::Response do
  subject(:response) do
    described_class.new(
      body: pdf_body,
      status: 200,
      headers: headers,
      content_type: 'application/pdf'
    )
  end

  let(:pdf_body) { '%PDF-1.4 fake content' }
  let(:headers) { { 'content-type' => 'application/pdf', 'x-generation-time' => '150ms' } }

  describe '#pdf?' do
    it 'returns true for PDF content type' do
      expect(response).to be_pdf
    end

    it 'returns false for non-PDF content type' do
      resp = described_class.new(body: '{}', status: 200, headers: {}, content_type: 'application/json')
      expect(resp).not_to be_pdf
    end
  end

  describe '#generation_time' do
    it 'returns the X-Generation-Time header' do
      expect(response.generation_time).to eq('150ms')
    end

    it 'returns nil when header is missing' do
      resp = described_class.new(body: '', status: 200, headers: {}, content_type: nil)
      expect(resp.generation_time).to be_nil
    end
  end

  describe '#save' do
    it 'writes the body to a file' do
      path = File.join(Dir.tmpdir, 'test_output.pdf')
      response.save(path)

      expect(File.binread(path)).to eq(pdf_body)
    ensure
      FileUtils.rm_f(path)
    end
  end

  describe '#size' do
    it 'returns the byte size of the body' do
      expect(response.size).to eq(pdf_body.bytesize)
    end

    it 'returns 0 when body is nil' do
      resp = described_class.new(body: nil, status: 200, headers: {}, content_type: nil)
      expect(resp.size).to eq(0)
    end
  end
end
