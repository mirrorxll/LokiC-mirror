# frozen_string_literal: true

module Limpar
  module Route
    module Editorials

      API = '/api/v1'

      # Limpar::Client.new.create_editorial({topic_id: 'd3e33afa-0103-4eab-8b2d-63c6ce09b5a0', description: 'Education About', kind: 'Person', person_id: '0a698245-618a-47a0-a55c-0eace865c6d3'})
      def create_editorial(body = {})
        post("#{API}/editorials", body)
      end

      def delete_editorial(id)
        delete("#{API}/editorials/#{id}")
      end
    end
  end
end
