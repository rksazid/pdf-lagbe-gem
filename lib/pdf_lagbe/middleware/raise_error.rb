# frozen_string_literal: true

module PdfLagbe
  module Middleware
    class RaiseError < Faraday::Middleware
      def on_complete(env)
        return if (200..299).cover?(env.status)

        error_class = PdfLagbe::ERROR_MAP[env.status] ||
                      (env.status >= 500 ? PdfLagbe::ServerError : PdfLagbe::ClientError)

        message = extract_message(env)

        raise error_class.new(
          message,
          status: env.status,
          response_body: env.body,
          response_headers: env.response_headers
        )
      end

      private

      def extract_message(env)
        body = safe_parse_json(env.body)

        if body.is_a?(Hash)
          body[:error] || body[:message] || "HTTP #{env.status}"
        else
          env.body.to_s[0, 200]
        end
      end

      def safe_parse_json(body)
        JSON.parse(body, symbolize_names: true)
      rescue JSON::ParserError, TypeError
        body
      end
    end
  end
end
