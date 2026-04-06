# frozen_string_literal: true

module PdfLagbe
  class Error < StandardError
    attr_reader :status, :response_body, :response_headers

    def initialize(message = nil, status: nil, response_body: nil, response_headers: nil)
      @status = status
      @response_body = response_body
      @response_headers = response_headers
      super(message || default_message)
    end

    private

    def default_message
      'PdfLagbe API error'
    end
  end

  # 4xx Client Errors
  class ClientError < Error; end

  class BadRequestError < ClientError
    private

    def default_message
      'Bad request: validation failed'
    end
  end

  class PayloadTooLargeError < ClientError
    private

    def default_message
      'Payload too large: HTML exceeds 2 MB limit'
    end
  end

  class RateLimitError < ClientError
    def retry_after
      response_headers&.[]('retry-after')&.to_i
    end

    private

    def default_message
      'Rate limit exceeded'
    end
  end

  # 5xx Server Errors
  class ServerError < Error; end

  class TimeoutError < ServerError
    private

    def default_message
      'Request timed out during PDF rendering'
    end
  end

  class ServiceUnavailableError < ServerError
    def retry_after
      response_headers&.[]('retry-after')&.to_i
    end

    private

    def default_message
      'Service unavailable: server at capacity'
    end
  end

  # Network Errors
  class ConnectionError < Error
    private

    def default_message
      'Connection failed'
    end
  end

  ERROR_MAP = {
    400 => BadRequestError,
    408 => TimeoutError,
    413 => PayloadTooLargeError,
    429 => RateLimitError,
    503 => ServiceUnavailableError
  }.freeze
end
