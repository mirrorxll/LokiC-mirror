# frozen_string_literal: true

module MultiTasks
  class CommentsController < MultiTasksController
    before_action :find_multi_task
    before_action :find_comment, only: %i[edit update destroy]

    after_action  :send_notification, only: :create
    after_action  :find_comments, only: %i[update destroy]

    def new
      @comment = Comment.new
    end

    def create
      @comment = @multi_task.comments.build(subtype: comment_params[:subtype], body: comment_params[:body])
      @comment.commentator =current_account
      @comment.save!
      @comment.assignment_to << comment_assignment_to
    end

    def edit; end

    def update
      @comment.update!(body: params[:body])
    end

    def destroy
      @comment.destroy
    end

    private

    def find_comments
      @comments = @multi_task.comments.order(created_at: :desc)
    end

    def find_comment
      @comment = Comment.find(params[:id])
    end

    def find_task
      @multi_task = MultiTask.find(params[:multi_task_task_id])
    end

    def comment_params
      params.require(:comment).permit(:body, :subtype, assignment_to: [])
    end

    def comment_assignment_to
      comment_params[:assignment_to].blank? ? [] : Account.find(comment_params[:assignment_to])
    end

    def send_notification
      return unless @comment

      accounts = @comment.assignment? ? @comment.assignment_to : ((@multi_task.assignment_to.to_a << @multi_task.creator) - [@comment.commentator]).uniq
      accounts.each do |account|
        next if account.slack.nil? || account.slack.deleted

        message = "*<#{multi_task_url(@multi_task)}| TASK ##{@multi_task.id}> | "\
                "#{@comment.commentator.name} add comment | Check please*\n>#{@multi_task.title}"

        ::SlackNotificationJob.perform_async(account.slack.identifier, message)
        ::SlackNotificationJob.perform_async('hle_lokic_task_reminders', message)
      end
    end
  end
end
