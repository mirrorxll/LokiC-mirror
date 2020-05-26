# frozen_string_literal: true

class CreationsController < ApplicationController # :nodoc:
  def create
    # render_400 && return unless @story_type.iteration.creation.nil?

    CreationJob.set(wait: 2.second).perform_later(@story_type)
    @story_type.update_iteration(creation: false)
  end

  def purge_all
    # render_400 && return unless @story_type.iteration.creation.nil?

    PurgeSamplesByLastIterationJob.set(wait: 2.second).perform_later(@story_type)
    @story_type.update_iteration(purge_last_creation: false)
  end
end
