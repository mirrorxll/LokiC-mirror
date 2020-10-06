# frozen_string_literal: true

class DevelopersProductionsController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type

  def index
    @rows_reports = ExportedStoryType.begin_date(Date.today.prev_month)

    filter_params.each do |key, value|
      @rows_reports = @rows_reports.public_send(key, value) if value.present?
    end

    @rows_reports = @rows_reports.select("week_id,
                                          sum(count_samples) as sum_total,
                                          sum(if(first_export = 1, count_samples, 0)) as sum_first_export,
                                          sum(if(first_export != 1, count_samples, 0)) as sum_follow_up_export,
                                          count(if(first_export = 1, 1, NULL)) as count_first,
                                          count(if(first_export != 1, 1, NULL)) as count_follow_up").group(:week_id).order(week_id: :desc)
  end

  private

  def filter_params
    return {} unless params[:filter]

    params.require(:filter).slice(:begin_date, :developer)
  end
end
