# frozen_string_literal: true

# sending notifications to a browser
# when changed one of the story type statuses
class FactoidTypeChannel < ApplicationCable::Channel
  def subscribed
    stream_for FactoidType.find(params[:factoid_type_id])
  end
end
