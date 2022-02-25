# frozen_string_literal: true

class PressReleaseReportsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  def index
    report_press_release = Reports::PressReleaseReport.new
    @clients_names = report_press_release.clients_names
    @data_for_bar = report_press_release.data_for_grid_bar
    @client_counts = report_press_release.clients_counts
    @max_week = report_press_release.max_week
  end
end
