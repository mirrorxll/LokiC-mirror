# frozen_string_literal: true

module StoryTypes
  class SchedulesController < ApplicationController # :nodoc:
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

    before_action :render_403, if: :editor?

    def manual
      @iteration.update!(schedule: false, current_account: current_account)

      send_to_action_cable(@story_type, 'scheduler', 'scheduling in progress')
      SchedulerJob.perform_async(@iteration.id, :manual, { params: manual_params, account: current_account.id })

      render 'hide_section'
    end

    def backdate
      @iteration.update!(schedule: false, current_account: current_account)

      send_to_action_cable(@story_type, 'scheduler', 'scheduling in progress')
      SchedulerJob.perform_async(@iteration.id, :backdate, { params: backdated_params, account: current_account.id })

      render 'hide_section'
    end

    def auto
      @iteration.update!(schedule: false, current_account: current_account)

      send_to_action_cable(@story_type, 'scheduler', 'scheduling in progress')
      SchedulerJob.perform_async(@iteration.id, :auto, { params: auto_params, account: current_account.id })

      render 'hide_section'
    end

    def purge
      @iteration.stories.update_all(published_at: nil, backdated: 0)
      counts = { scheduled: 0, backdated: 0 }
      @iteration.update!(schedule: nil,
                         schedule_args: nil,
                         schedule_counts: @iteration.schedule_counts.merge(counts),
                         current_account: current_account)
      flash.now[:message] = 'scheduling purged'
    end

    def show_form
      @type = type_params[:type]
    end

    private

    def manual_params
      params.require(:manual).permit!.to_hash
    end

    def backdated_params
      params.require(:backdate).permit!.to_hash
    end

    def type_params
      params.permit(:type, :story_type_id, :iteration_id)
    end

    def auto_params
      (params[:auto].blank? ? {} : params.require(:auto).permit!).to_hash
    end

    def update_section_params
      params.require(:section_update).permit(:message)
    end
  end
end
