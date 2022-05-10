# frozen_string_literal: true

namespace :story_type do
  namespace :backdate do
    desc 'Story Type backdate-export'
    task export: :environment do
      StoryTypes::BackdateExportTask.new.perform
    end
  end
end
