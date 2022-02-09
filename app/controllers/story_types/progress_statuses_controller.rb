# frozen_string_literal: true

module StoryTypes
  class ProgressStatusesController < ApplicationController
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

    before_action :render_403, if: :editor?
    before_action :find_status

    before_save :change_archived

    def change
      # change_archived if @status.name == 'archived' || @story_type.status.name == 'archived'
      @story_type.update!(status: @status, last_status_changed_at: Time.now, current_account: current_account)
      # pp "> "*50, @story_type.status.name_previous_change
      # pp "> "*50, @story_type.status.name_was
      # pp "> "*50, @story_type.status.previous_changes[:name]
    end

    private

    def change_archived
      pp " *"*50, @story_type.status
      # @story_type.archived ? @story_type.update!(archived: false) : @story_type.update!(archived: true)
    end

    def find_status
      @status = Status.find(params[:status_id])
    end
  end
end
