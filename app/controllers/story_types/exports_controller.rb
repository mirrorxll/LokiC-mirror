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
    before_action :opportunities_attached?, only: :execute

    def execute
      @iteration.update!(export: false, current_account: current_account)
      send_to_action_cable(@story_type, 'export', 'export in progress')

      url = stories_story_type_iteration_exports_url(params[:story_type_id], params[:iteration_id])

      Process.spawn(
        "cd #{Rails.root} && RAILS_ENV=#{Rails.env} "\
        'rake story_type:iteration:export '\
        "iteration_id=#{@iteration.id} account_id=#{current_account.id} url='#{url}' &"
      )
    end

    def remove_exported_stories
      @removal.update!(removal_params)
      @iteration.update!(purge_export: true, current_account: current_account)
      send_to_action_cable(@story_type, 'export', 'removing from PL in progress')

      Process.spawn(
        "cd #{Rails.root} && RAILS_ENV=#{Rails.env} "\
        'rake story_type:iteration:purge_export '\
        "iteration_id=#{@iteration.id} account_id=#{current_account.id} &"
      )
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
      url = generate_url(@story_type)
      channel = @story_type.developer.slack_identifier
      message = "Static year in the template for <#{url}|Story Type ##{@story_type.id}> must be revised to unlock export!"
      section = :export
      flash_message = {
        iteration_id: @iteration.id,
        message: {
          key: section,
          section => 'Editor must revise the template to unlock export!'
        }
      }
      # flash message
      StoryTypeChannel.broadcast_to(@story_type, flash_message)
      # slack message
      ::SlackNotificationJob.new.perform(channel, message)

      render json: { status: :ok }
    end

    def opportunities_attached?
      publication_ids = @iteration.stories.pluck(:publication_id).uniq
      st_opportunities = @story_type.opportunities.where(publication_id: publication_ids)
      return unless st_opportunities.any? { |st_o| st_o[:opportunity_id].nil? }

      url = generate_url(@story_type)
      developer = @story_type.developer.slack_identifier
      manager = Account.find_by(first_name: 'Sergey', last_name: 'Burenkov').slack_identifier
      message = "[ LokiC ] <#{url}|Story Type ##{@story_type.id}> has "\
                'clients/publications without attached opportunities. Export was blocked!'
      flash_message = {
        iteration_id: @iteration.id,
        message: {
          key: :export,
          export: 'Story Type has clients/publications without attached opportunities.'
        }
      }
      # flash message
      StoryTypeChannel.broadcast_to(@story_type, flash_message)
      # slack message
      ::SlackNotificationJob.new.perform(developer, message)
      ::SlackNotificationJob.new.perform(manager, message)

      render json: { status: :ok }
    end
  end
end
