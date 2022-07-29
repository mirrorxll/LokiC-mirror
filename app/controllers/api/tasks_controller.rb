# frozen_string_literal: true

module Api
  class TasksController < Api::ApiController
    def titles
      task_titles = MultiTask.where(creator: params[:creator_id]).map(&:title)

      render json: task_titles
    end

    def subtasks
      task = MultiTask.find(params[:id])

      render json: { subtasks: task.subtasks }
    end
  end
end
