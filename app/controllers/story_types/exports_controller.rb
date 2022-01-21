# frozen_string_literal: true

module StoryTypes
  class ExportsController < ApplicationController
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

    before_action :render_403_editor, except: :stories, if: :editor?
    before_action :render_403_developer, only: %i[stories submit_editor_report submit_manager_report], if: :developer?
    before_action :show_sample_ids, only: :stories
    before_action :removal, only: :remove_exported_stories
    before_action :revision_reminder, only: :execute, if: :template_with_expired_revision

    def execute
      @iteration.update!(export: false, current_account: current_account)
      url = stories_story_type_iteration_exports_url(params[:story_type_id], params[:iteration_id])

      send_to_action_cable(@story_type, 'export', 'export in progress')
      ExportJob.perform_later(@iteration, current_account, url)
    end

    def remove_exported_stories
      @iteration.update!(purge_export: true, current_account: current_account)
      @removal.update!(removal_params)

      send_to_action_cable(@story_type, 'export', 'removing from PL in progress')
      PurgeExportJob.perform_later(@iteration, current_account)
    end

    def stories
      @stories =
        if params[:backdated]
          @iteration.stories.exported
        else
          @iteration.stories.exported_without_backdate
        end

      @stories =
        @stories.order(backdated: :asc, published_at: :asc).page(params[:page]).per(25)
                .includes(:output, :publication)
    end

    private

    def removal
      recent_removal = @iteration.production_removals.last

      @removal =
        if recent_removal&.status.eql?(false)
          recent_removal
        else
          @iteration.production_removals.create(account: current_account)
        end
    end

    def removal_params
      params.require(:remove_exported_stories).permit(:reasons)
    end

    def show_sample_ids
      @show_sample_ids = {}
      @iteration.show_samples.map { |smpl| @show_sample_ids[smpl.pl_story_id] = smpl.id }
    end

    def revision_reminder
      channel = @story_type.editor.slack_identifier
      message = "You have to revise template for Story Type #{@story_type.id} to unlock export for developer!"
      section = :export
      flash_message = {
        iteration_id: @iteration.id,
        message: {
          key: section,
          section => 'Editor has to revise the template to unlock export!'
        }
      }
      # flash message for developer
      StoryTypeChannel.broadcast_to(@story_type, flash_message)
      # slack message for editor
      ::SlackNotificationJob.perform_now(channel, message)

      render json: { status: :ok }
    end
  end
end
