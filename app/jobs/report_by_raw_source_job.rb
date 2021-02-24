# frozen_string_literal: true

class ReportByRawSourceJob < ApplicationJob
  queue_as :lokic

  def perform(*args)
    Report::ReportByRawSource.report
  end
end
