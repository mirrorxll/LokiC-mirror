# frozen_string_literal: true

# sending notifications to a browser
# when changed one of the story type statuses
class ImportTrackingReportChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'ImportTrackingReportChannel'
  end
end
