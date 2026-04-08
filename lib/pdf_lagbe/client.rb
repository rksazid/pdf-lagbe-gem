# frozen_string_literal: true

module PdfLagbe
  class Client
    include Connection

    attr_reader :config

    def initialize(**options)
      @config = if options.any?
                  build_config(options)
                else
                  PdfLagbe.configuration
                end
    end

    def html_to_pdf
      @html_to_pdf ||= Resources::HtmlToPdf.new(self)
    end

    def markdown_to_pdf
      @markdown_to_pdf ||= Resources::MarkdownToPdf.new(self)
    end

    def docx_to_pdf
      @docx_to_pdf ||= Resources::DocxToPdf.new(self)
    end

    def health
      @health ||= Resources::Health.new(self)
    end

    def info
      @info ||= Resources::Info.new(self)
    end

    private

    def build_config(options)
      cfg = PdfLagbe.configuration.dup
      options.each do |key, value|
        cfg.public_send(:"#{key}=", value)
      end
      cfg
    end
  end
end
