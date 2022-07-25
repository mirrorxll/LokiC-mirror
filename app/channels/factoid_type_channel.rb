# frozen_string_literal: true

# sending notifications to a browser
# when changed one of the story type statuses
class FactoidTypeChannel < ApplicationCable::Channel
  def subscribed
    pp '1111111111111111111'*100, params[:factoid_type_id], FactoidType.find(params[:factoid_type_id])
    stream_for FactoidType.find(params[:factoid_type_id])
  end
end
