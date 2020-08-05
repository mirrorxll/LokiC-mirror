# frozen_string_literal: true

class ReportByRawSourceJob < ApplicationJob
  queue_as :report_mm

  def perform(*args)
    Report::ReportByRawSource.report
  end

end
