# frozen_string_literal: true

class ReportForMmJob < ApplicationJob
  queue_as :report_mm

  def perform(*args)
    Report::ReportForMM.report
  end

end
