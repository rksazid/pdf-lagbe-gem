# frozen_string_literal: true

require 'faraday'
require 'faraday/multipart'
require 'faraday/retry'
require 'json'

require_relative 'pdf_lagbe/version'
require_relative 'pdf_lagbe/configuration'
require_relative 'pdf_lagbe/errors'
require_relative 'pdf_lagbe/middleware/raise_error'
require_relative 'pdf_lagbe/connection'
require_relative 'pdf_lagbe/response'
require_relative 'pdf_lagbe/resources/base'
require_relative 'pdf_lagbe/resources/pdf_options'
require_relative 'pdf_lagbe/resources/html_to_pdf'
require_relative 'pdf_lagbe/resources/markdown_to_pdf'
require_relative 'pdf_lagbe/resources/docx_to_pdf'
require_relative 'pdf_lagbe/resources/health'
require_relative 'pdf_lagbe/resources/info'
require_relative 'pdf_lagbe/client'

module PdfLagbe
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def client
      @client ||= Client.new
    end

    def reset!
      @configuration = Configuration.new
      @client = nil
    end
  end
end
