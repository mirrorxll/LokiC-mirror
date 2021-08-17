# frozen_string_literal: true

module StoryTypes
  class CreationsController < ApplicationController # :nodoc:
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

    before_action :render_403, if: :editor?

    def execute
      @iteration.update!(creation: false, current_account: current_account)
      CreationJob.perform_later(@iteration, current_account)
    end

    def purge
      if @iteration.stories.where.not("pl_#{PL_TARGET}_story_id" => nil).present?
        flash.now[:error] = 'At least one story from this iteration has already exported to PL'
      else
        @iteration.update!(purge_stories: true, current_account: current_account)
        PurgeStoriesByIterationJob.perform_later(@iteration, current_account)
      end
    end
  end
end
