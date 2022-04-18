# frozen_string_literal: true

class ReportForMmJob < ApplicationJob
  sidekiq_options queue: :lokic

  def perform(*args)
    Report::ReportForMM.report
  end

end
