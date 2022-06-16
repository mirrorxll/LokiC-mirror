# frozen_string_literal: true

# sending notifications to a browser
# when changed one of the story type statuses
class ExportedFactoidsChannel < ApplicationCable::Channel
  def subscribed
    stream_for ArticleTypeIteration.find(params[:article_type_iteration_id])
  end
end

