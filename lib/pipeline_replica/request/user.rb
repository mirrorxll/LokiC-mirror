# frozen_string_literal: true

module PipelineReplica
  module Request
    # requests return user data or nil
    module User
      def get_user_by_api_token(token)
        return if token.nil?

        job_q = get_user_by_api_token_query(token)
        @pl_replica.query(job_q).to_a.last
      end

      private

      def get_user_by_api_token_query(token)
        'SELECT u.email, u.display_name '\
        "FROM users u JOIN tokens t ON u.id = t.tokenable_id AND tokenable_type = 'User' "\
        "WHERE authentication_token = '#{Mysql2::Client.escape(token)}'"
      end
    end
  end
end
