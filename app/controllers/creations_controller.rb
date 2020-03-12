# frozen_string_literal: true

class CreationsController < ApplicationController # :nodoc:
  def execute
    CreationJob.perform_async(@story_type.id)
  end

  def purge
    PurgeLastCreationJob.perform_async(@story_type.id)
  end
end
