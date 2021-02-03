# frozen_string_literal: true

class CreationsController < ApplicationController # :nodoc:
  before_action :render_400, if: :editor?

  def create
    CreationJob.set(wait: 1.second).perform_later(@iteration)

    @iteration.update(creation: false)
  end

  def purge_all
    if @iteration.samples.where.not("pl_#{PL_TARGET}_story_id" => nil).present?
      flash.now[:error] = 'At least one story from this iteration has already exported to PL.'
    else
      RemoveSamplesByLastIterationJob.set(wait: 1.second).perform_later(@iteration)

      @story_type.iteration.update(purge_all_samples: true)
    end
  end
end

