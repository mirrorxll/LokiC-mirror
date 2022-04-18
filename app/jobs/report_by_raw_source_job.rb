# frozen_string_literal: true

class ReportByRawSourceJob < ApplicationJob
  sidekiq_options queue: :lokic

  def perform(*args)
    Report::ReportByRawSource.report
  end
end
