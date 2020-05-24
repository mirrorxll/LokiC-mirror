# frozen_string_literal: true

class CreationsController < ApplicationController # :nodoc:
  def create
    render_400 && return unless @story_type.iteration.creation.nil?

    CreationJob.set(wait: 5.second).perform_later(@story_type)
    @story_type.update_iteration(creation: false)
  end

  def purge_all
    @story_type.iteration.destroy
    @story_type.update_iteration(creation: nil)
  end
end
