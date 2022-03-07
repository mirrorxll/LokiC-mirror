# frozen_string_literal: true

namespace :scrape_task do
  desc 'update change_history'
  task change_history: :environment do
    ChangeHistory.all.each do |ch_h|
      body = Note.find(ch_h[:note_id]).note
      event = HistoryEvent.find(ch_h[:history_event_id]).name

      ch_h.update!(body: body, event: event)
      print '.'
    end

    puts
  end

  desc 'update alerts'
  task alerts: :environment do
    Alert.all.each do |al|
      body = Note.find(al[:note_id]).note
      subtype = AlertSubtype.find(al[:subtype_id]).name

      al.update!(body: body, subtype: subtype)
      print '.'
    end

    puts
  end

  desc 'insert hosts'
  task hosts: :environment do
    %w[DB01 DB02 DB04 DB06 DB07 DB10 DB13 DB14 DB15].each { |h| Host.create(name: h) }
  end
end
