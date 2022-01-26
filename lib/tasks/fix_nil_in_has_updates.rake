# frozen_string_literal: true

namespace :reminder do
  desc 'updates nil values in has_updates'
  task fix_nil_in_has_updates: :environment do
    Reminder.where(has_updates: nil).each do |reminder|
      reminder.update(has_updates: false)
    end
  end
end
