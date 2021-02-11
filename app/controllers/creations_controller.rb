# frozen_string_literal: true

class CreationsController < ApplicationController # :nodoc:
  before_action :render_400, if: :editor?

  def create
    @iteration.update(creation: false)
    CreationJob.set(wait: 2.seconds).perform_later(@iteration)
  end

  def purge_all
    if @iteration.samples.where.not("pl_#{PL_TARGET}_story_id" => nil).present?
      flash.now[:error] = 'At least one story from this iteration has already exported to PL.'
    else
      @story_type.iteration.update(purge_all_samples: true)
      RemoveSamplesByLastIterationJob.set(wait: 2.seconds).perform_later(@iteration)
    end
  end
end

