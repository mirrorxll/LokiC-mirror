# frozen_string_literal: true

class TrackingHoursController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type
  before_action :find_week, only: %i[index create confirm assembleds google_sheets]

  def index
    @rows_reports = TrackingHour.all.where(developer: current_account, week: @week)
    @confirm = ConfirmReport.find_by(developer: current_account, week: @week)
  end

  def new
    @report = TrackingHour.new
  end

  def create
    params[:report].values.each do |row|
      TrackingHour.create!(developer: current_account,
                           type_of_work: TypeOfWork.find_by(name: row['type_of_work']),
                           client: ClientsReport.find_by(name: row['client']),
                           week: @week,
                           hours: row['hours'],
                           date: row['date'],
                           comment: row['comment'])
    end
    @rows_reports = TrackingHour.all.where(developer: current_account, week: @week)
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

  def properties; end

  def import_data
    Reports::ImportTrackingHours.from_google_drive(params[:url], params[:worksheet], params[:range], current_account, previous_week)
    @rows_reports = TrackingHour.all.where(developer: current_account)
  end

  def confirm
    if params[:confirm].to_i == 1
      ConfirmReport.create(developer: current_account, week: @week)
      Reports::HoursAsm.q(TrackingHour.where(developer: current_account, week: @week))
    else
      ConfirmReport.find_by(developer: current_account, week: @week).delete
      Assembled.where(developer: current_account, week: @week).destroy_all
    end
  end

  def google_sheets
    AssembledsJob.set(wait: 2.seconds).perform_now(@week)
  end

  def assembleds
    @assemleds = Assembled.where(week: @week)
    @link = LinkAssembled.find_by(week: @week)
  end

  private

  def find_week
    @week = Week.find(params[:week])
  end

  def find_row_reports
    @rows_reports = TrackingHour.all.where(developer: current_account)
  end

  def row_report_params
    params.require(:report).permit(:hours, :type_of_work_id, :client_id, :date, :comment)
  end
end
