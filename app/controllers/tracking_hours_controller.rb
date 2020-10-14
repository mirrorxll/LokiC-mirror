# frozen_string_literal: true

class TrackingHoursController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type
  before_action :find_row_reports, only: %i[index]
  after_action :find_row_reports, only: %i[create]

  def index

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

  def import_data; end

  def google_sheets
    assembleds = Assembled.where(date: Date.today - (Date.today.wday - 1))
    @link = Reports::Assembled2020.to_google_drive(assembleds)
  end

  def assembled_2020
    @rows_reports = []
    @tracking_hours = TrackingHour.where(week: previous_week)
    @tracking_hours.select(:developer_id).group(:developer_id).each do |el|
      @rows_reports += Reports::HoursAsm.q(@tracking_hours.where(developer: el.developer_id))
    end
    @rows_reports.each do |row|
      Assembled.create(date: row['Date'],
                       dept: row['Dept'],
                       name: row['Name'],
                       updated_description: row['Updated Description'],
                       oppourtunity_name: row['Oppourtunity Name'],
                       oppourtunity_id: row['Oppourtunity ID'],
                       old_product_name: row['Old Product Name'],
                       sf_product_id: row['SF Product ID'],
                       client_name: row['Client Name'],
                       account_name: row['Account Name'],
                       hours: row['Hours'],
                       employment_classification: row['Employment Classification'])
    end

  end

  private

  def find_row_reports
    @rows_reports = TrackingHour.all.where(developer: current_account)
  end

  def previous_week
    Week.where(end_week: Date.today - Date.today.wday).first
  end

  def row_report_params
    params.require(:report).permit(:hours, :type_of_work_id, :client_id, :date, :comment)
  end
end
