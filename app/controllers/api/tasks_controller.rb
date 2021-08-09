# frozen_string_literal: true

module Api
  class TasksController < Api::ApiController
    def titles
      task_titles = Task.where(creator: params[:creator_id]).map(&:title)

      render json: task_titles
    end
  end
end
