# frozen_string_literal: true

RSpec.describe PdfLagbe::Resources::HtmlToPdf do
  include_context 'with stubbed connection'

  let(:pdf_binary) { '%PDF-1.4 fake' }
  let(:pdf_headers) { { 'content-type' => 'application/pdf', 'x-generation-time' => '120ms' } }

  describe '#convert' do
    before do
      stubs.post('/api/v1/pdf') { [200, pdf_headers, pdf_binary] }
    end

    it 'returns a Response with PDF body' do
      result = client.html_to_pdf.convert(html: '<h1>Hello</h1>')

      expect(result).to be_a(PdfLagbe::Response)
      expect(result.body).to eq(pdf_binary)
      expect(result).to be_pdf
    end

    it 'returns the generation time' do
      result = client.html_to_pdf.convert(html: '<p>Test</p>')
      expect(result.generation_time).to eq('120ms')
    end

    it 'passes options in the request body' do
      stubs.instance_variable_get(:@stack).clear # clear the before stub

      stubs.post('/api/v1/pdf') do |env|
        body = JSON.parse(env.body)
        expect(body['format']).to eq('A4')
        expect(body['landscape']).to be(true)
        [200, pdf_headers, pdf_binary]
      end

      client.html_to_pdf.convert(html: '<p>Test</p>', format: 'A4', landscape: true)
    end
  end

  describe '#convert_to_file' do
    it 'saves PDF to a file and returns the response' do
      stubs.post('/api/v1/pdf') { [200, pdf_headers, pdf_binary] }

      path = File.join(Dir.tmpdir, 'test_convert.pdf')
      result = client.html_to_pdf.convert_to_file(html: '<p>Hi</p>', output_path: path)

      expect(result).to be_a(PdfLagbe::Response)
      expect(File.binread(path)).to eq(pdf_binary)
    ensure
      FileUtils.rm_f(path)
    end
  end

  describe 'validation' do
    it 'raises ArgumentError when html is nil' do
      expect { client.html_to_pdf.convert(html: nil) }
        .to raise_error(ArgumentError, 'html is required')
    end

    it 'raises ArgumentError when html is empty' do
      expect { client.html_to_pdf.convert(html: '') }
        .to raise_error(ArgumentError, 'html is required')
    end

    it 'raises ArgumentError when html exceeds 2 MB' do
      huge_html = 'x' * ((2 * 1024 * 1024) + 1)
      expect { client.html_to_pdf.convert(html: huge_html) }
        .to raise_error(ArgumentError, 'html exceeds 2 MB limit')
    end

    it 'raises ArgumentError for invalid format' do
      expect { client.html_to_pdf.convert(html: '<p>x</p>', format: 'B5') }
        .to raise_error(ArgumentError, /format must be one of/)
    end

    it 'raises ArgumentError for out-of-range scale' do
      expect { client.html_to_pdf.convert(html: '<p>x</p>', scale: 3.0) }
        .to raise_error(ArgumentError, /scale must be between/)
    end

    it 'raises ArgumentError for oversized headerTemplate' do
      big_template = 'x' * ((10 * 1024) + 1)
      expect { client.html_to_pdf.convert(html: '<p>x</p>', headerTemplate: big_template) }
        .to raise_error(ArgumentError, /headerTemplate exceeds/)
    end

    it 'raises ArgumentError for out-of-range waitForTimeout' do
      expect { client.html_to_pdf.convert(html: '<p>x</p>', waitForTimeout: 6000) }
        .to raise_error(ArgumentError, /waitForTimeout must be between/)
    end

    it 'accepts valid options without error' do
      stubs.post('/api/v1/pdf') { [200, pdf_headers, pdf_binary] }

      expect do
        client.html_to_pdf.convert(
          html: '<p>Test</p>',
          format: 'A4',
          landscape: true,
          scale: 1.5,
          margin: { top: '10mm', bottom: '10mm', left: '5mm', right: '5mm' },
          printBackground: true,
          waitForTimeout: 2000
        )
      end.not_to raise_error
    end
  end
end
