# frozen_string_literal: true

class ArticleTypesJob < ApplicationJob
  sidekiq_options queue: :factoid

  private

  def send_to_action_cable(article_type, section, message)
    message_to_send = {
      iteration_id: article_type.iteration.id,
      message: {
        key: section,
        section => message
      }
    }

    pp '>>>>>>>>>>>>>>>>>', article_type, message_to_send
    ArticleTypeChannel.broadcast_to(article_type, message_to_send)
  end
end
