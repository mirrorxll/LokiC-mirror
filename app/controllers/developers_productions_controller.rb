# frozen_string_literal: true

class DevelopersProductionsController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration

  def exported_counts
    @rows_reports = ExportedStoryType.begin_date(Date.today.prev_month)

    filter_params_counts.each do |key, value|
      @rows_reports = ExportedStoryType.all.public_send(key, value) if value.present?
    end

    @rows_reports = @rows_reports.select("week_id,
                                          sum(count_samples) as sum_total,
                                          sum(if(first_export = 1, count_samples, 0)) as sum_first_export,
                                          sum(if(first_export != 1, count_samples, 0)) as sum_follow_up_export,
                                          count(if(first_export = 1, 1, NULL)) as count_first,
                                          count(if(first_export != 1, 1, NULL)) as count_follow_up").group(:week_id).order(week_id: :desc)
  end

  def scores
    default_date = Date.today.prev_month < Date.parse('2020-11-02') ? '2020-11-02' : Date.today.prev_month
    @exported_story_types = ExportedStoryType.begin_date(default_date)

    @begin_date = filter_params[:begin_date].nil? || filter_params[:begin_date] == '' ? default_date : filter_params[:begin_date]

    filter_params.each do |key, value|
      @exported_story_types = ExportedStoryType.public_send(key, value) if value.present?
    end

    @rows_reports = []

    developers.each do |dev|
      count_first = @exported_story_types.where(developer: dev, first_export: true).count
      count_follow_up = @exported_story_types.where(developer: dev, first_export: false).count * 0.15

      score = count_first + count_follow_up
      tracking_hours = TrackingHour.where(developer: dev).where("date >= ?", @begin_date).select("type_of_work_id, sum(hours) as sum").group(:type_of_work_id)
      hours = tracking_hours.sum { |el| el.sum }
      @rows_reports << {
        developer: dev,
        score: score,
        hours: hours,
        hours_per_story: score == 0 ? 0 : (hours / score).round(2)
      }
    end
    @rows_reports = @rows_reports.sort_by {|row| row[:score]}.reverse
  end

  def show_hours
    @developer = Account.find(params[:developer])
    begin_date = params[:begin_date]
    @row_reports = TrackingHour.where(developer: @developer).where("date >= ?", begin_date).group(:type_of_work).sum(:hours)
  end

  private

  def filter_params
    return {} unless params[:filter]

    unless params[:filter][:begin_date].nil? || params[:filter][:begin_date] == ''
      params[:filter][:begin_date] = '2020-11-02' if Date.parse(params[:filter][:begin_date]) < Date.parse('2020-11-02')
    end

    params.require(:filter).slice(:begin_date, :developer)
  end

  def filter_params_counts
    return {} unless params[:filter]

    params.require(:filter).slice(:begin_date, :developer)
  end

  def developers
    Account.all
  end
end
