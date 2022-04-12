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

      def factoid_post(sample)
        article_type = sample.article_type
        staging_table_name = article_type.staging_table.name
        limpar_year, limpar_id = Table.get_limpar_data(staging_table_name)
        factoid_kind = "#{article_type.kind.name.downcase}_id"

        params = {
          topic_id: article_type.topic.external_lp_id,
          description: article_type.topic.description,
          year: limpar_year,
          source_type: article_type.source_type,
          source_name: article_type.source_name,
          source_link: article_type.source_link,
          original_publish_date: Date.today,

          kind: article_type.kind.parent_kind.id
        }
        params.merge!("#{factoid_kind}".to_sym => limpar_id)
        pp '===================', params

        # response = @lp_client.
      end
    end
  end
end
