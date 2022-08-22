# frozen_string_literal: true

class PressReleaseReportsController < ApplicationController
  def index
    @tab_title = "LokiC :: PressReleaseReports"
  end

  def get_report
    PressReleaseReportJob.perform_async
  end

  def show_report
    @data = {}
    @data[:clients_names] = report_params[:clients_names]
    @data[:for_bar] = report_params[:for_bar]
    @data[:clients_counts] = report_params[:clients_counts]
    @data[:max_week] = report_params[:max_week]
  end

  private

  def report_params
    report_params = params.permit( :max_week, clients_names: [], for_bar: {}, clients_counts: {} )
    report_params[:clients_counts] = report_params[:clients_counts].to_h.map { |_k,v| v }
    report_params[:for_bar] = report_params[:for_bar].to_h.map { |_k,v| v }
    report_params
  end
end
