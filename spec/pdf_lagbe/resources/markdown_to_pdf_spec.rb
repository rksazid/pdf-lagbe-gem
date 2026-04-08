# frozen_string_literal: true

RSpec.describe PdfLagbe::Resources::MarkdownToPdf do
  include_context 'with stubbed connection'

  let(:pdf_binary) { '%PDF-1.4 fake' }
  let(:pdf_headers) { { 'content-type' => 'application/pdf', 'x-generation-time' => '95ms' } }

  describe '#convert' do
    before do
      stubs.post('/api/v1/md-to-pdf') { [200, pdf_headers, pdf_binary] }
    end

    it 'returns a Response with PDF body' do
      result = client.markdown_to_pdf.convert(markdown: '# Hello World')

      expect(result).to be_a(PdfLagbe::Response)
      expect(result.body).to eq(pdf_binary)
      expect(result).to be_pdf
    end

    it 'returns the generation time' do
      result = client.markdown_to_pdf.convert(markdown: '## Test')
      expect(result.generation_time).to eq('95ms')
    end

    it 'passes options in the request body' do
      stubs.instance_variable_get(:@stack).clear

      stubs.post('/api/v1/md-to-pdf') do |env|
        body = JSON.parse(env.body)
        expect(body['markdown']).to eq('# Hello')
        expect(body['format']).to eq('A4')
        expect(body['landscape']).to be(true)
        [200, pdf_headers, pdf_binary]
      end

      client.markdown_to_pdf.convert(markdown: '# Hello', format: 'A4', landscape: true)
    end
  end

  describe '#convert_to_file' do
    it 'saves PDF to a file and returns the response' do
      stubs.post('/api/v1/md-to-pdf') { [200, pdf_headers, pdf_binary] }

      path = File.join(Dir.tmpdir, 'test_md.pdf')
      result = client.markdown_to_pdf.convert_to_file(markdown: '# Test', output_path: path)

      expect(result).to be_a(PdfLagbe::Response)
      expect(File.binread(path)).to eq(pdf_binary)
    ensure
      FileUtils.rm_f(path)
    end
  end

  describe 'validation' do
    it 'raises ArgumentError when markdown is nil' do
      expect { client.markdown_to_pdf.convert(markdown: nil) }
        .to raise_error(ArgumentError, 'markdown is required')
    end

    it 'raises ArgumentError when markdown is empty' do
      expect { client.markdown_to_pdf.convert(markdown: '') }
        .to raise_error(ArgumentError, 'markdown is required')
    end

    it 'raises ArgumentError when markdown exceeds 2 MB' do
      huge_md = 'x' * ((2 * 1024 * 1024) + 1)
      expect { client.markdown_to_pdf.convert(markdown: huge_md) }
        .to raise_error(ArgumentError, 'markdown exceeds 2 MB limit')
    end

    it 'raises ArgumentError for invalid format' do
      expect { client.markdown_to_pdf.convert(markdown: '# Hi', format: 'B5') }
        .to raise_error(ArgumentError, /format must be one of/)
    end

    it 'raises ArgumentError for out-of-range scale' do
      expect { client.markdown_to_pdf.convert(markdown: '# Hi', scale: 3.0) }
        .to raise_error(ArgumentError, /scale must be between/)
    end

    it 'accepts valid options without error' do
      stubs.post('/api/v1/md-to-pdf') { [200, pdf_headers, pdf_binary] }

      expect do
        client.markdown_to_pdf.convert(
          markdown: '# Test',
          format: 'A4',
          landscape: true,
          scale: 1.5,
          printBackground: true
        )
      end.not_to raise_error
    end
  end
end
