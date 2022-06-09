# frozen_string_literal: true

class MultiTasksController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :set_story_type_iteration
  skip_before_action :find_parent_article_type
  skip_before_action :set_article_type_iteration

  private

  def find_multi_task
    @multi_task = Task.find(params[:multi_task_id] || params[:id])
  end
end
