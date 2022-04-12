# frozen_string_literal: true

module StoryTypes
  class CreationsController < ApplicationController # :nodoc:
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

    before_action :render_403, if: :editor?

    def execute
      @iteration.update!(creation: false, current_account: current_account)

      send_to_action_cable(@story_type, 'samples', 'creation in the process')
      CreationJob.perform_async(@iteration.id, current_account.id)
    end

    def purge
      if @iteration.stories.where.not("pl_#{PL_TARGET}_story_id" => nil).present?
        flash.now[:error] = 'At least one story from this iteration has already exported to PL'
      else
        @iteration.update!(purge_creation: true, current_account: current_account)

        send_to_action_cable(@story_type, 'samples', 'purging in progress')
        PurgeCreationJob.perform_async(@iteration.id, current_account.id)
      end
    end
  end
end
