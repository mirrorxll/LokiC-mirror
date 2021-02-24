# frozen_string_literal: true

class ReportForMmJob < ApplicationJob
  queue_as :lokic

  def perform(*args)
    Report::ReportForMM.report
  end

end
