# frozen_string_literal: true

module PdfLagbe
  class Response
    attr_reader :body, :status, :headers, :content_type

    def initialize(body:, status:, headers:, content_type:)
      @body = body
      @status = status
      @headers = headers
      @content_type = content_type
    end

    def pdf?
      content_type&.include?('application/pdf')
    end

    def generation_time
      headers&.[]('x-generation-time')
    end

    def save(path)
      File.binwrite(path, body)
      path
    end

    def size
      body&.bytesize || 0
    end
  end
end
