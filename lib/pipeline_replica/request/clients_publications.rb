# frozen_string_literal: true

module PipelineReplica
  module Request
    # request return job or nil
    module ClientPublication
      def get_clients_publications
        @pl_replica.query(get_clients_publications_query).to_a
      end

      private

      def get_clients_publications_query
        'SELECT cc.id client_id, cc.name client_name, comm.id publication_id, '\
        'comm.name publication_name FROM client_companies cc JOIN communities comm '\
        'ON cc.id = comm.client_company_id;'
      end
    end
  end
end
