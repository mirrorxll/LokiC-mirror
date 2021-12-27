# frozen_string_literal: true

class WorkRequestsJob < ApplicationJob
  queue_as :work_request
end
