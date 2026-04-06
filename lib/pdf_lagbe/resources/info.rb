# frozen_string_literal: true

module PdfLagbe
  module Resources
    class Info < Base
      ENDPOINT = '/'

      def fetch
        response = get(ENDPOINT)
        parse_json(response)
      end
    end
  end
end
