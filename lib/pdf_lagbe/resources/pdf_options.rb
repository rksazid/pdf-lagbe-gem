# frozen_string_literal: true

module PdfLagbe
  module Resources
    module PdfOptions
      VALID_FORMATS     = %w[A4 Letter A3 Legal Tabloid].freeze
      MAX_TEMPLATE_SIZE = 10 * 1024 # 10 KB
      SCALE_RANGE       = (0.1..2.0)
      TIMEOUT_RANGE     = (0..5000)

      private

      def validate_pdf_options!(opts)
        validate_format!(opts[:format]) if opts.key?(:format)
        validate_scale!(opts[:scale]) if opts.key?(:scale)
        validate_template!(:headerTemplate, opts[:headerTemplate]) if opts.key?(:headerTemplate)
        validate_template!(:footerTemplate, opts[:footerTemplate]) if opts.key?(:footerTemplate)
        validate_wait_for_timeout!(opts[:waitForTimeout]) if opts.key?(:waitForTimeout)
      end

      def validate_format!(format)
        return if VALID_FORMATS.include?(format.to_s)

        raise ArgumentError, "format must be one of: #{VALID_FORMATS.join(', ')}"
      end

      def validate_scale!(scale)
        return if SCALE_RANGE.cover?(scale.to_f)

        raise ArgumentError, 'scale must be between 0.1 and 2.0'
      end

      def validate_template!(name, template)
        return if template.bytesize <= MAX_TEMPLATE_SIZE

        raise ArgumentError, "#{name} exceeds 10 KB limit"
      end

      def validate_wait_for_timeout!(timeout)
        return if TIMEOUT_RANGE.cover?(timeout.to_i)

        raise ArgumentError, 'waitForTimeout must be between 0 and 5000'
      end
    end
  end
end
