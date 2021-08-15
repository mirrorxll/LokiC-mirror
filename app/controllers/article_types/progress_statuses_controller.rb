# frozen_string_literal: true

module ArticleTypes
  class ProgressStatusesController < ApplicationController
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration

    before_action :render_403, if: :editor?
    before_action :find_status

    def change
      @story_type.update!(status: @status, last_status_changed_at: Time.now, current_account: current_account)
    end

    private

    def find_status
      @status = Status.find(params[:status_id])
    end
  end
end
