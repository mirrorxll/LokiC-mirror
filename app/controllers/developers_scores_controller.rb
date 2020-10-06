# frozen_string_literal: true

class DevelopersScoresController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type

  def index
    @rows_reports = ExportedStoryType.begin_date(Date.today.prev_month)

  end

  private

  def filter_params
    return {} unless params[:filter]

    params.require(:filter).slice(:begin_date, :developer)
  end
end
