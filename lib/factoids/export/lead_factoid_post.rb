# frozen_string_literal: true

# POST params example
#   required(:topic_id).filled(:uuid)
#   required(:description).filled(:string)
#   optional(:year).value(:integer, gt?: 0)
#   optional(:source_type).filled(:string)
#   optional(:source_name).filled(:string)
#   optional(:source_link).filled(:string)
#   optional(:original_publish_date).filled(:date)
#
#   # virtual attributes
#
#   required(:kind).filled(KindsEnum)
#   optional(:person_id).filled(:uuid)
#   optional(:organization_id).filled(:uuid)
#   optional(:state_id).filled(:uuid)
#   optional(:county_id).filled(:uuid)

module Factoids
  module Export
    module LeadFactoidPost
      private

      def factoid_post(sample, limpar_columns)
        exported_date = DateTime.now
        params        = prepare_params(sample, limpar_columns)
      begin
        response      = @lp_client.create_editorial(params)
      rescue Faraday::UnauthorizedError
        return
      end
        factoid_id    = JSON.parse(response.body)['data']['id']

        sample.update!(limpar_factoid_id: factoid_id, exported_at: exported_date)
      end

      def prepare_params(sample, limpar_columns)
        article_type                 = sample.article_type
        st_limpar_id                 = limpar_columns['limpar_id']
        st_limpar_year               = limpar_columns['limpar_year']
        factoid_kind                 = "#{article_type.kind.name.downcase}_id"

        raise ArgumentError, 'LimparId must be provided!' unless st_limpar_id

        params = {
          kind: article_type.kind.name,
          "#{factoid_kind}".to_sym => st_limpar_id,
          topic_id: article_type.topic.external_lp_id,
          description: sample.body
        }
        %w[source_type source_name source_link original_publish_date].each do |field|
          params.merge!("#{field}".to_sym => article_type[field.to_sym]) if article_type[field.to_sym]
        end
        params.merge!(year: st_limpar_year) if st_limpar_year
        params
      end
    end
  end
end
