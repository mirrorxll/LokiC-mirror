# frozen_string_literal: true

class CreationsController < ApplicationController # :nodoc:
  def create
    CreationJob.set(wait: 2.second).perform_later(@story_type)
    @story_type.update_iteration(creation: false)

    render 'processing'
  end

  def purge_all
    PurgeSamplesByLastIterationJob.set(wait: 2.second).perform_later(@story_type)
    @story_type.update_iteration(purge_last_samples: false)

    render 'processing'
  end
end
