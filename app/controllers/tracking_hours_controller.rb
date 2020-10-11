# frozen_string_literal: true

class TrackingHoursController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type

  def index

    @rows_reports = TrackingHour.all.where(developer: current_account)

    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def new
    @report = TrackingHour.new
  end

  def create
    @report = TrackingHour.new(row_report_params)
    @report.developer = current_account
    @report.save!

    @rows_reports = TrackingHour.all.where(account: current_account)
  end

  def update

  end

  def destroy

  end

  def add_form; end

  def exclude_row
    @row_report = TrackingHour.find(params[:id]).delete
    @row_id = params[:id]
  end

  def google_sheets
    puts '////'
    @link = Reports::Assembled.to_google_drive
  end

  def assembled_2020
    @rows_reports = []
    @tracking_hours = TrackingHour.where(week: previous_week)
    @tracking_hours.select(:developer_id).group(:developer_id).each do |el|
      @rows_reports += Reports::HoursAsm.q(@tracking_hours.where(developer: el.developer_id))
    end
    puts '.....'
    puts @rows_reports
  end

  private
  def previous_week
    Week.where(end_week: Date.today - Date.today.wday).first
  end

  def row_report_params
    params.require(:report).permit(:hours, :type_of_work_id, :client_id, :date, :comment)
  end
end
