# frozen_string_literal: true

class ExportedStoryTypesController < ApplicationController # :nodoc:
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration

  def index
    @rows_reports = ExportedStoryType.order(date_export: :desc)

    filter_params.each do |key, value|
      @rows_reports = @rows_reports.public_send(key, value) if value.present?
    end
  end

  private

  def filter_params
    return {} unless params[:filter]

    params.require(:filter).slice(:begin_date, :developer)
  end
end
