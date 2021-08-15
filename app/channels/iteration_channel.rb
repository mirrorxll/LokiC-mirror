# frozen_string_literal: true

# sending notifications to a browser
# when changed one of the story type statuses
class IterationChannel < ApplicationCable::Channel
  def subscribed
    model =
      if params[:story_type_iteration_id]
        StoryType.find(params[:story_type_iteration_id])
      elsif params[:article_type_iteration_id]
        ArticleType.find(params[:article_type_iteration_id])
      end

    stream_for model
  end
end
