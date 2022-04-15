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

      def factoid_post(sample, st_limpar_columns)
        article_type = sample.article_type
        st_limpar_year, st_limpar_id = st_limpar_columns
        factoid_kind = "#{article_type.kind.name.downcase}_id"
        exported_date = DateTime.now

        raise ArgumentError, 'LimparId must be provided!' unless st_limpar_id
        raise ArgumentError, 'LimparYear must be provided!' unless st_limpar_year

        params = {
          topic_id: article_type.topic.external_lp_id,
          description: sample.body,
          year: st_limpar_year,
          source_type: article_type.source_type,
          source_name: article_type.source_name,
          source_link: article_type.source_link,
          original_publish_date: article_type.original_publish_date,

          kind: article_type.kind.name,
          "#{factoid_kind}".to_sym => st_limpar_id
        }
        pp '===================', params

        response = @lp_client.create_editorial(params)
        pp '111111111111111', response
        factoid_id = JSON.parse(response.body)['data']['id']

        sample.update!(limpar_factoid_id: factoid_id, exported_at: exported_date)
      end
    end
  end
end
