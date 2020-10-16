# frozen_string_literal: true

class TrackingHoursController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type
  before_action :find_row_reports, only: %i[index]
  after_action :find_row_reports, only: %i[create]

  def index
    @confirm = ConfirmReport.find_by(developer: current_account, week: previous_week)
  end

  def new
    @report = TrackingHour.new
  end

  def create
    params[:report].values.each do |row|
      TrackingHour.create!(developer: current_account,
                           type_of_work: TypeOfWork.find_by(name: row['type_of_work']),
                           client: ClientsReport.find_by(name: row['client']),
                           week: previous_week,
                           hours: row['hours'],
                           date: row['date'],
                           comment: row['comment'])
    end
    @rows_reports = TrackingHour.all.where(developer: current_account)
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

  def show_modal; end

  def import_data
    Reports::ImportTrackingHours.from_google_drive(params[:url], params[:worksheet], params[:range], current_account, previous_week)
    @rows_reports = TrackingHour.all.where(developer: current_account)
  end

  def confirm
    if params[:confirm].to_i == 1
      ConfirmReport.create(developer: current_account, week: previous_week)
      Reports::HoursAsm.q(TrackingHour.where(developer: current_account, week: previous_week))
    else
      ConfirmReport.find_by(developer: current_account, week: previous_week).delete
      Assembled.where(developer: current_account, week: previous_week).delete
    end
  end

  def google_sheets
    assembleds = Assembled.where(date: Date.today - (Date.today.wday - 1))
    @link = Reports::Assembled2020.to_google_drive(assembleds)
  end

  def assembleds
    @assemleds = Assembled.where(week: previous_week)
  end

  private

  def find_row_reports
    @rows_reports = TrackingHour.all.where(developer: current_account)
  end

  def previous_week
    Week.where(end: Date.today - Date.today.wday).first
  end

  def row_report_params
    params.require(:report).permit(:hours, :type_of_work_id, :client_id, :date, :comment)
  end
end
