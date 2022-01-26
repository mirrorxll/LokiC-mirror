# frozen_string_literal: true

class RootController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_story_type_iteration
  skip_before_action :find_parent_article_type
  skip_before_action :set_article_type_iteration

  def index
    path =
      if only_scraper?
        scrape_tasks_path
      elsif client?
        new_work_request_path
      elsif outside_manager?
        work_requests_path(archived: false)
      elsif guest_1? || guest_2?
        tasks_path
      else
        story_types_path
      end

    redirect_to path
  end
end
