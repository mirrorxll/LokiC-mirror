# frozen_string_literal: true

namespace :factoid_type do
  namespace :iteration do
    desc "purge exported factoids"
    task purge_exported_factoids: :environment do
      FactoidTypes::Iterations::PurgeFactoidsTask.new.perform(ENV['iteration_id'], ENV['account_id'], ENV['factoid_ids'])
    end
  end
end
