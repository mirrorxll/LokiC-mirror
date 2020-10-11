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

  def assembled_2020
    @assembleds = Assembled.all
  end

  private

  def row_report_params
    params.require(:report).permit(:hours, :type_of_work_id, :clients_report_id, :date, :comment)
  end
end
