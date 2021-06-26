# frozen_string_literal: true

namespace :story_type do
  desc 'replace messages to other table'
  task replace_messages: :environment do
    Alert.all.each do |a|
      txt = Text.find_or_create_by!(text: a.message)
      a.update(message_id: txt.id)
    end
  end

  desc 'replace notes to other table'
  task replace_notes: :environment do
    ChangeHistory.all.each do |a|
      txt = Text.find_or_create_by!(text: a.notes)
      a.update(note_id: txt.id)
    end
  end
end
