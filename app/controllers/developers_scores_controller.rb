# frozen_string_literal: true

class DevelopersScoresController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  def index
    @rows_reports = ExportedStoryType.begin_date(Date.today.prev_month)
  end

  private

  def filter_params
    return {} unless params[:filter]

    params.require(:filter).slice(:begin_date, :developer)
  end
end
