# frozen_string_literal: true

module PdfLagbe
  module Resources
    class HtmlToPdf < Base
      include PdfOptions

      ENDPOINT      = '/api/v1/html-to-pdf'
      MAX_HTML_SIZE = 2 * 1024 * 1024 # 2 MB

      def convert(html:, **options)
        validate_html!(html)
        validate_pdf_options!(options)

        body = build_body(html, options)
        response = post(ENDPOINT, body)

        Response.new(
          body: response.body,
          status: response.status,
          headers: response.headers,
          content_type: response.headers['content-type']
        )
      end

      def convert_to_file(html:, output_path:, **options)
        result = convert(html: html, **options)
        result.save(output_path)
        result
      end

      private

      def validate_html!(html)
        raise ArgumentError, 'html is required' if html.nil? || html.empty?
        raise ArgumentError, 'html exceeds 2 MB limit' if html.bytesize > MAX_HTML_SIZE
      end

      def build_body(html, options)
        { html: html }.merge(options.compact)
      end
    end
  end
end
