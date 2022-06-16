# frozen_string_literal: true

class FactoidTypesTask < ApplicationTask
  private

  def send_to_action_cable(article_type, section, message)
    message_to_send = {
      iteration_id: article_type.iteration.id,
      message: {
        key: section,
        section => message
      }
    }

    ArticleTypeChannel.broadcast_to(article_type, message_to_send)
    ExportedFactoidsChannel.broadcast_to(article_type.iteration, message_to_send)
  end
end
