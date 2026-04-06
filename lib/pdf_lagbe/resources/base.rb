# frozen_string_literal: true

module PdfLagbe
  module Resources
    class Base
      attr_reader :client

      def initialize(client)
        @client = client
      end

      private

      def connection
        client.connection
      end

      def post(path, body = {}, headers = {})
        connection.post(path) do |req|
          req.headers.merge!(headers)
          req.body = body
        end
      end

      def get(path, params = {})
        connection.get(path, params)
      end

      def parse_json(response)
        JSON.parse(response.body, symbolize_names: true)
      end
    end
  end
end
