# frozen_string_literal: true

class CreationsController < ApplicationController # :nodoc:
  before_action :render_403, if: :editor?

  def execute
    @iteration.update(creation: false)
    CreationJob.perform_later(@iteration)
  end

  def purge_all
    if @iteration.samples.where.not("pl_#{PL_TARGET}_story_id" => nil).present?
      flash.now[:error] = 'At least one story from this iteration has already exported to PL'
    else
      @iteration.update(purge_all_samples: true)
      RemoveSamplesByLastIterationJob.perform_later(@iteration)
    end
  end
end
