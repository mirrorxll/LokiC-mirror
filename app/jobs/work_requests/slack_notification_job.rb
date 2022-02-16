# frozen_string_literal: true

module WorkRequests
  class SlackNotificationJob < WorkRequestsJob
    def perform(work_request, raw_message, requester = nil)
      work_requester = requester || work_request.requester

      url = generate_url(work_request)
      message = "*Work Request <#{url} |  #{work_request.project_order_name.body}> | #{work_requester.name}*\n>#{raw_message}"

      ::SlackNotificationJob.perform_now('lokic_work_request_messages', message)
    end
  end
end
