# frozen_string_literal: true

class TaskReceiptsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  before_action :find_task_receipt

  def confirm
    @task_receipt.update(confirmed: params[:confirm])
    @task_receipts = TaskReceipt.where(task: params[:task_id])
  end

  private

  def find_task_receipt
    @task_receipt = TaskReceipt.find_by(task: params[:task_id], assignment: current_account)
  end
end
