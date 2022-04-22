# frozen_string_literal: true

module Limpar
  module Route
    module Editorials

      API = '/api/v1'

      def create_editorial(body = {})
        post("#{API}/editorials", body)
      end

      def delete_editorial(id)
        delete("#{API}/editorials/#{id}")
      end
    end
  end
end
