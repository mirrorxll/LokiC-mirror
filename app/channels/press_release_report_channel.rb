# frozen_string_literal: true

# sending notifications to a browser
# when changed one of the story type statuses
class PressReleaseReportChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'PressReleaseReportChannel'
  end
end
