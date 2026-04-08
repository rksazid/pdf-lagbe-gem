# frozen_string_literal: true

module PdfLagbe
  module Connection
    def connection
      @connection ||= build_connection
    end

    private

    def build_connection
      Faraday.new(url: config.base_url) do |f|
        f.request :multipart
        f.request :json
        f.request :retry,
                  max: config.max_retries,
                  interval: config.retry_interval,
                  exceptions: retry_exceptions

        f.response :logger, config.logger, bodies: true if config.logger

        f.use PdfLagbe::Middleware::RaiseError

        f.headers['User-Agent'] = config.user_agent
        f.options.open_timeout  = config.open_timeout
        f.options.timeout       = config.read_timeout
        f.proxy = config.proxy if config.proxy

        adapter = config.faraday_adapter
        if adapter.is_a?(Array)
          f.adapter(*adapter)
        else
          f.adapter adapter
        end
      end
    end

    def retry_exceptions
      [
        Faraday::ConnectionFailed,
        Faraday::TimeoutError
      ]
    end
  end
end
