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

  def create

  end

  def update

  end

  def destroy

  end

  def exclude_row
    puts params
    @row_report = ReportTrackingHour.find(params[:id]).delete
    @row_id = params[:id]
  end

end
