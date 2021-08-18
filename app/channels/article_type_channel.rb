# frozen_string_literal: true

# sending notifications to a browser
# when changed one of the story type statuses
class ArticleTypeChannel < ApplicationCable::Channel
  def subscribed
    stream_for ArticleType.find(params[:article_type_id])
  end
end
