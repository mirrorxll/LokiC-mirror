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
    @row_report = ReportTrackingHour.new
  end

  def create
    @row_report = ReportTrackingHour.new(row_report_params)
    puts '////'
    puts @row_report.hours
    @row_report.save
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
    params.require(:row_report).permit(:hours, :type_of_work, :client, :date, :comment)
  end
end
