# frozen_string_literal: true

module WorkRequests
  class SlackNotificationJob < WorkRequestsJob
    def perform(work_request, raw_message, requester = nil)
      work_requester = requester || work_request.requester
      channel = Rails.env.production? ? 'lokic_work_request_messages' : 'hle_lokic_development_messages'

      url = generate_url(work_request)
      message = "*<#{url} | Work Request> | #{work_requester.name}*\n>#{raw_message}"

      ::SlackNotificationJob.perform_now(channel, message)
    end
  end
end
