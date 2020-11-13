# frozen_string_literal: true

class TrackingHoursController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration

  before_action :find_week, only: %i[index create confirm assembleds google_sheets properties import_data]

  def index
    @rows_reports = row_reports(@week)
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
    Assembled.destroy_current(current_account, @week)
    Reports::HoursAsm.q(row_reports(@week))
    @rows_reports = row_reports(@week)
  end

  def add_form; end

  def exclude_row
    @row_report = TrackingHour.find(params[:id])
    week = @row_report.week
    @row_report.delete
    Assembled.destroy_current(current_account, week)
    @row_reports = row_reports(week)
    Reports::HoursAsm.q(@row_reports) unless @row_reports.empty?
    @row_id = params[:id]
  end

  def properties; end

  def import_data
    Assembled.destroy_current(current_account, @week)
    ImportTrackingReportJob.set(wait: 2.seconds).perform_later(params[:url], params[:worksheet], params[:range], current_account, @week)

    @rows_reports = row_reports(@week)
  end

  def google_sheets
    link = LinkAssembled.find_by(week: @week)
    link.update_attribute(:in_process, true) unless link.nil?
    AssembledsJob.set(wait: 2.seconds).perform_later(@week, link)
  end

  def assembleds
    @assemleds = Assembled.where(week: @week)
    @link = LinkAssembled.find_by(week: @week)
  end

  def dev_hours
    @week = params[:week]
    @developer = params[:developer]
    @rows_reports = row_reports(@week)
  end

  private

  def assembleds_destroy
    Assembled.where(developer: current_account, week: @week).destroy_all
  end

  def find_week
    @week = params[:week].nil? ? Week.find_by(begin: Date.today.beginning_of_week.last_week) : Week.find(params[:week])
  end

  def row_reports(week)
    TrackingHour.where(developer: current_account, week: week).order(:date)
  end

  def row_report_params
    params.require(:report).each{ |report| report.values.permit(:hours, :type_of_work_id, :client_id, :date) }
  end
end
