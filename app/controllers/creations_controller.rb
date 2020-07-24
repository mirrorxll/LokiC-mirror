# frozen_string_literal: true

class CreationsController < ApplicationController # :nodoc:
  before_action :render_400, if: :editor?

  def create
    CreationJob.set(wait: 2.second).perform_later(@story_type)
    @story_type.update_iteration(creation: false)
  end

  def purge_all
    PurgeSamplesByLastIterationJob.set(wait: 2.second).perform_later(@story_type)
    @story_type.update_iteration(
      purge_all_samples: false, creation: nil,
      schedule: nil, schedule_args: nil, export: nil
    )
  end
end
