# frozen_string_literal: true

class CreationsController < ApplicationController # :nodoc:
  before_action :render_403, if: :editor?

  def execute
    @iteration.update!(creation: false, current_account: current_account)
    CreationJob.perform_later(@iteration, current_account: current_account)
  end

  def purge_all
    if @iteration.stories.where.not("pl_#{PL_TARGET}_story_id" => nil).present?
      flash.now[:error] = 'At least one story from this iteration has already exported to PL'
    else
      @iteration.update!(purge_all_stories: true, current_account: current_account)
      RemoveSamplesByIterationJob.perform_later(@iteration, current_account)
    end
  end
end
