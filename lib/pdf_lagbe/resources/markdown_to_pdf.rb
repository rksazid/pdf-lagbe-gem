# frozen_string_literal: true

module PdfLagbe
  module Resources
    class MarkdownToPdf < Base
      include PdfOptions

      ENDPOINT          = '/api/v1/md-to-pdf'
      MAX_MARKDOWN_SIZE = 2 * 1024 * 1024 # 2 MB

      def convert(markdown:, **options)
        validate_markdown!(markdown)
        validate_pdf_options!(options)

        body = build_body(markdown, options)
        response = post(ENDPOINT, body)

        Response.new(
          body: response.body,
          status: response.status,
          headers: response.headers,
          content_type: response.headers['content-type']
        )
      end

      def convert_to_file(markdown:, output_path:, **options)
        result = convert(markdown: markdown, **options)
        result.save(output_path)
        result
      end

      private

      def validate_markdown!(markdown)
        raise ArgumentError, 'markdown is required' if markdown.nil? || markdown.empty?
        raise ArgumentError, 'markdown exceeds 2 MB limit' if markdown.bytesize > MAX_MARKDOWN_SIZE
      end

      def build_body(markdown, options)
        { markdown: markdown }.merge(options.compact)
      end
    end
  end
end
