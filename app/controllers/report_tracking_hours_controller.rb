# frozen_string_literal: true

class ReportTrackingHoursController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type

  def index
    @rows_reports = ReportTrackingHour.all.where(account: current_account)

    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def new
    @report = ReportTrackingHour.new
    puts '////new'
    puts params
  end

  def create
    puts row_report_params
    @report_tracking_hour = ReportTrackingHour.new(row_report_params)
    @report_tracking_hour.account = current_account
    @report_tracking_hour.save!

    @rows_reports = ReportTrackingHour.all.where(account: current_account)
  end

  def update

  end

  def destroy

  end

  def add_form; end

  def exclude_row
    @row_report = ReportTrackingHour.find(params[:id]).delete
    @row_id = params[:id]
  end

  private

  def row_report_params
    params.require(:report).permit(:hours, :type_of_work_id, :client_id, :date, :comment)
  end
end
