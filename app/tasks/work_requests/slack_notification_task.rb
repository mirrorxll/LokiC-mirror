# frozen_string_literal: true

module WorkRequests
  class SlackNotificationTask < ApplicationTask
    def perform(work_request_id, raw_message)
      work_request = WorkRequest.find(work_request_id)
      work_requester = work_request.requester

      url = generate_url(work_request)
      message = "*Work Request <#{url}|#{work_request.project_order_name.body}> | #{work_requester.name}*\n>#{raw_message}"

      ::SlackNotificationTask.new.perform('lokic_work_request_messages', message)
    end
  end
end
