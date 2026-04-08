# frozen_string_literal: true

RSpec.describe PdfLagbe::Resources::DocxToPdf do
  include_context 'with stubbed connection'

  let(:pdf_binary) { '%PDF-1.4 fake' }
  let(:pdf_headers) { { 'content-type' => 'application/pdf', 'x-generation-time' => '200ms' } }
  let(:docx_path) { File.join(Dir.tmpdir, 'test_input.docx') }

  before do
    File.binwrite(docx_path, 'fake docx content')
  end

  after do
    FileUtils.rm_f(docx_path)
  end

  describe '#convert' do
    it 'returns a Response with PDF body' do
      stubs.post('/api/v1/docx-to-pdf') { [200, pdf_headers, pdf_binary] }

      result = client.docx_to_pdf.convert(file_path: docx_path)

      expect(result).to be_a(PdfLagbe::Response)
      expect(result.body).to eq(pdf_binary)
      expect(result).to be_pdf
    end

    it 'returns the generation time' do
      stubs.post('/api/v1/docx-to-pdf') { [200, pdf_headers, pdf_binary] }

      result = client.docx_to_pdf.convert(file_path: docx_path)
      expect(result.generation_time).to eq('200ms')
    end

    it 'sends multipart form data with options' do
      stubs.post('/api/v1/docx-to-pdf') do |env|
        expect(env.request_headers['Content-Type']).to include('multipart/form-data')
        [200, pdf_headers, pdf_binary]
      end

      client.docx_to_pdf.convert(file_path: docx_path, format: 'Letter', landscape: true)
    end
  end

  describe '#convert_to_file' do
    it 'saves PDF to a file and returns the response' do
      stubs.post('/api/v1/docx-to-pdf') { [200, pdf_headers, pdf_binary] }

      output_path = File.join(Dir.tmpdir, 'test_docx_output.pdf')
      result = client.docx_to_pdf.convert_to_file(file_path: docx_path, output_path: output_path)

      expect(result).to be_a(PdfLagbe::Response)
      expect(File.binread(output_path)).to eq(pdf_binary)
    ensure
      FileUtils.rm_f(output_path)
    end
  end

  describe 'validation' do
    it 'raises ArgumentError when file_path is nil' do
      expect { client.docx_to_pdf.convert(file_path: nil) }
        .to raise_error(ArgumentError, 'file_path is required')
    end

    it 'raises ArgumentError when file_path is empty' do
      expect { client.docx_to_pdf.convert(file_path: '') }
        .to raise_error(ArgumentError, 'file_path is required')
    end

    it 'raises ArgumentError when file does not exist' do
      expect { client.docx_to_pdf.convert(file_path: '/nonexistent/file.docx') }
        .to raise_error(ArgumentError, /file not found/)
    end

    it 'raises ArgumentError for non-.docx files' do
      txt_path = File.join(Dir.tmpdir, 'test.txt')
      File.write(txt_path, 'hello')

      expect { client.docx_to_pdf.convert(file_path: txt_path) }
        .to raise_error(ArgumentError, 'file must be a .docx file')
    ensure
      FileUtils.rm_f(txt_path)
    end

    it 'raises ArgumentError when file exceeds 5 MB' do
      large_path = File.join(Dir.tmpdir, 'large.docx')
      File.binwrite(large_path, 'x' * ((5 * 1024 * 1024) + 1))

      expect { client.docx_to_pdf.convert(file_path: large_path) }
        .to raise_error(ArgumentError, 'file exceeds 5 MB limit')
    ensure
      FileUtils.rm_f(large_path)
    end

    it 'raises ArgumentError for invalid format' do
      expect { client.docx_to_pdf.convert(file_path: docx_path, format: 'B5') }
        .to raise_error(ArgumentError, /format must be one of/)
    end

    it 'accepts valid options without error' do
      stubs.post('/api/v1/docx-to-pdf') { [200, pdf_headers, pdf_binary] }

      expect do
        client.docx_to_pdf.convert(file_path: docx_path, format: 'A4', landscape: true)
      end.not_to raise_error
    end
  end
end
