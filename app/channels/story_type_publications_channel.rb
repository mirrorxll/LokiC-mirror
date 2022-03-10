class StoryTypePublicationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for StoryType.find(params[:story_type_id])
  end
end
