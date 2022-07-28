# frozen_string_literal: true

namespace :factoid_type do
  namespace :setup do
    desc 'rename article_type to factoid_type'
    task rename_at_to_ft: :environment do
      Alert.where(alert_type: 'ArticleType').each { |alert| alert.update!(alert_type: 'FactoidType') }
      ChangeHistory.where(history_type: 'ArticleType').each { |change_history| change_history.update!(history_type: 'FactoidType') }
      FactCheckingDoc.where(fcdable_type: 'ArticleType').each { |fact_checking_docs| fact_checking_docs.update!(fcdable_type: 'FactoidType') }
      SidekiqBreak.where(breakable_type: 'ArticleType').each { |sidekiq_breaks| sidekiq_breaks.update!(breakable_type: 'FactoidType') }
      StagingTable.where(staging_tableable_type: 'ArticleType').each { |staging_tables| staging_tables.update!(staging_tableable_type: 'FactoidType') }
      Template.where(templateable_type: 'ArticleType').each { |templates| templates.update!(templateable_type: 'FactoidType') }
    end
  end
end
