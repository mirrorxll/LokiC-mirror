# frozen_string_literal: true

# sending notifications to a browser
# when population status set to true
class StoryTypeChannel < ApplicationCable::Channel
  def subscribed
    story_type = StoryType.find(params[:story_type_id])
    stream_for story_type
  end
end
