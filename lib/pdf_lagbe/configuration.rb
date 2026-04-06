# frozen_string_literal: true

module PdfLagbe
  class Configuration
    attr_accessor :base_url, :open_timeout, :read_timeout, :write_timeout,
                  :max_retries, :retry_interval, :logger, :user_agent,
                  :faraday_adapter, :proxy

    DEFAULT_BASE_URL       = 'https://pdf-lagbe.vercel.app'
    DEFAULT_OPEN_TIMEOUT   = 10
    DEFAULT_READ_TIMEOUT   = 30
    DEFAULT_WRITE_TIMEOUT  = 30
    DEFAULT_MAX_RETRIES    = 2
    DEFAULT_RETRY_INTERVAL = 1.0

    def initialize
      @base_url        = DEFAULT_BASE_URL
      @open_timeout    = DEFAULT_OPEN_TIMEOUT
      @read_timeout    = DEFAULT_READ_TIMEOUT
      @write_timeout   = DEFAULT_WRITE_TIMEOUT
      @max_retries     = DEFAULT_MAX_RETRIES
      @retry_interval  = DEFAULT_RETRY_INTERVAL
      @logger          = nil
      @user_agent      = "PdfLagbe Ruby/#{PdfLagbe::VERSION}"
      @faraday_adapter = Faraday.default_adapter
      @proxy           = nil
    end

    def to_h
      {
        base_url: base_url,
        open_timeout: open_timeout,
        read_timeout: read_timeout,
        write_timeout: write_timeout,
        max_retries: max_retries,
        retry_interval: retry_interval,
        logger: logger,
        user_agent: user_agent,
        faraday_adapter: faraday_adapter,
        proxy: proxy
      }
    end
  end
end
