# frozen_string_literal: true

module StoryTypes
  class ProgressStatusesController < ApplicationController
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

    before_action :render_403, if: :editor?
    before_action :find_status

    def change
      prev_status = @story_type.status
      @story_type.assign_attributes(status: @status, last_status_changed_at: Time.now, current_account: current_account)
      if @story_type.save
        change_archived if @status.name == 'archived' || prev_status.name == 'archived'
      end
    end

    private

    def change_archived
      @story_type.archived ? @story_type.update!(archived: false) : @story_type.update!(archived: true)
    end

    def find_status
      @status = Status.find(params[:status_id])
    end
  end
end
