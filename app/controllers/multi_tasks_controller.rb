# frozen_string_literal: true

class MultiTasksController < ApplicationController
  before_action -> { authorize!('multi_tasks') }

  private

  def find_multi_task
    @multi_task = Task.find(params[:multi_task_id] || params[:id])
  end
end
