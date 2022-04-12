# frozen_string_literal: true

class PressReleaseReportJob < ApplicationJob
  sidekiq_options queue: :lokic

  def perform(*_args)
    report_press_release = Reports::PressReleaseReport.new

    data = {}
    data[:clients_names] = report_press_release.clients_names
    data[:for_bar] = report_press_release.data_for_grid_bar.to_a
    data[:clients_counts] = report_press_release.clients_counts.to_a
    data[:max_week] = report_press_release.max_week

    ActionCable.server.broadcast('PressReleaseReportChannel', data)
  end
end
