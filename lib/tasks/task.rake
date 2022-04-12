# frozen_string_literal: true

namespace :task do
  desc 'Confirm task receipts'
  task confirm_receipts: :environment do
    TasksConfirmsReceiptsJob.new.perform
  end
end
