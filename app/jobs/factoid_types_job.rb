# frozen_string_literal: true

class FactoidTypesJob < ApplicationJob
  sidekiq_options queue: :factoid

  private

  def send_to_action_cable(factoid_type, section, message)
    message_to_send = {
      iteration_id: factoid_type.iteration.id,
      message: {
        key: section,
        section => message
      }
    }

    FactoidTypeChannel.broadcast_to(factoid_type, message_to_send)
  end
end
