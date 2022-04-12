# frozen_string_literal: true

module Limpar
  module Route
    module EditorialFactoids
      API = '/api/v1'

      def publish_factoid(params)
        post("#{API}/editorial_factoids", params)
      end
    end
  end
end

