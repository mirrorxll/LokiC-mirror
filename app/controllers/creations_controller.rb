# frozen_string_literal: true

class CreationsController < ApplicationController # :nodoc:
  def execute
    render_400 && return unless @story_type.iteration.creation.nil?

    CreationJob.set(wait: 1.second).perform_later(@story_type)
    @story_type.update_iteration(creation: false)
  end

  def purge
    # @story_type.iteration.purge
    # @story_type.update_iteration(create: nil)
  end
end
