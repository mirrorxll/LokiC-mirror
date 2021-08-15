# frozen_string_literal: true

module ArticleTypes
  class CreationsController < ApplicationController # :nodoc:
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration

    before_action :render_403, if: :editor?

    def execute
      @iteration.update!(creation: false, current_account: current_account)
      CreationJob.perform_later(@iteration, current_account: current_account)
    end

    def purge
      if @iteration.articles.where.not("pl_#{PL_TARGET}_story_id" => nil).present?
        flash.now[:error] = 'At least one story from this iteration has already exported to PL'
      else
        @iteration.update!(purge_stories: true, current_account: current_account)
        PurgeStoriesByIterationJob.perform_later(@iteration, current_account)
      end
    end
  end
end
