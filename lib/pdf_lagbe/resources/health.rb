# frozen_string_literal: true

module PdfLagbe
  module Resources
    class Health < Base
      ENDPOINT = '/health'

      def check
        response = get(ENDPOINT)
        parse_json(response)
      end
    end
  end
end
