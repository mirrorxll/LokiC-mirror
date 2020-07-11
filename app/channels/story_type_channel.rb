# frozen_string_literal: true

# sending notifications to a browser
# when changed one of the story type statuses
class StoryTypeChannel < ApplicationCable::Channel
  def subscribed
    stream_for StoryType.find(params[:story_type_id])
  end
end
