# frozen_string_literal: true

module PdfLagbe
  module Resources
    class DocxToPdf < Base
      ENDPOINT      = '/api/v1/docx-to-pdf'
      MAX_FILE_SIZE = 5 * 1024 * 1024 # 5 MB
      VALID_FORMATS = %w[A4 Letter A3 Legal Tabloid].freeze
      DOCX_MIME     = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'

      def convert(file_path:, **options)
        validate_file!(file_path)
        validate_options!(options)

        response = post_multipart(ENDPOINT, build_payload(file_path, options))

        Response.new(
          body: response.body,
          status: response.status,
          headers: response.headers,
          content_type: response.headers['content-type']
        )
      end

      def convert_to_file(file_path:, output_path:, **options)
        result = convert(file_path: file_path, **options)
        result.save(output_path)
        result
      end

      private

      def validate_file!(file_path)
        raise ArgumentError, 'file_path is required' if file_path.nil? || file_path.to_s.empty?
        raise ArgumentError, "file not found: #{file_path}" unless File.exist?(file_path)
        raise ArgumentError, 'file must be a .docx file' unless file_path.to_s.end_with?('.docx')
        raise ArgumentError, 'file exceeds 5 MB limit' if File.size(file_path) > MAX_FILE_SIZE
      end

      def validate_options!(opts)
        return unless opts.key?(:format)
        return if VALID_FORMATS.include?(opts[:format].to_s)

        raise ArgumentError, "format must be one of: #{VALID_FORMATS.join(', ')}"
      end

      def build_payload(file_path, options)
        payload = {
          file: Faraday::Multipart::FilePart.new(file_path, DOCX_MIME)
        }
        payload[:format] = options[:format].to_s if options.key?(:format)
        payload[:landscape] = options[:landscape].to_s if options.key?(:landscape)
        payload
      end

      def post_multipart(path, payload)
        connection.post(path) do |req|
          req.headers['Content-Type'] = 'multipart/form-data'
          req.body = payload
        end
      end
    end
  end
end
