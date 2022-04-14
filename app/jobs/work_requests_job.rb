# frozen_string_literal: true

class WorkRequestsJob < ApplicationJob
  sidekiq_options queue: :work_request
end
