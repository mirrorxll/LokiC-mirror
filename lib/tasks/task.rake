# frozen_string_literal: true

namespace :multi_task do
  desc 'Confirm task receipts'
  task confirm_receipts: :environment do
    TasksConfirmsReceiptsJob.new.perform
  end
end
