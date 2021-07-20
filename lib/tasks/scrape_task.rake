# frozen_string_literal: true

namespace :scrape_task do
  desc 'scrape_task_general_comment'
  task attach: :environment do
    subtype = CommentSubtype.find_or_create_by!(name: 'general comment')

    ScrapeTask.all.each do |sc_t|
      next if sc_t.general_comment

      sc_t.create_general_comment!(subtype: subtype)
      puts sc_t.id
    end
  end
end
