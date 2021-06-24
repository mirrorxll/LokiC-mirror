# frozen_string_literal: true

namespace :history do
  desc 'fill history events'
  task fill_events: :environment do
    events = [
      'created',
      'distributed',
      'progress status changed',
      'fact checking doc sent to reviewers',
      'fact checking doc sent to editors',
      'fact checking doc approved',
      'scheduled',
      'exported to pipeline',
      'updated without re-export',
      'removed from pipeline',
      'has updates',
      'new iteration created',
      'reminder turned off',
      'installed on cron',
      'cron turned off',
      'archived',
      'unarchived'
    ]

    events.each { |event| HistoryEvent.find_or_create_by!(name: event) }
  end
end
