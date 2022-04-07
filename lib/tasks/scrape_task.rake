# frozen_string_literal: true

namespace :scrape_task do
  desc 'Insert hosts'
  task hosts: :environment do
    %w[DB01 DB02 DB04 DB06 DB07 DB10 DB13 DB14 DB15].each do |h|
      Host.find_or_create_by(name: h)
    end
  end

  desc 'Sync schemes-tables with LokIC'
  task schemes_tables: :environment do
    ScrapeTasks::SchemesTablesJob.perform_now
  end
end
