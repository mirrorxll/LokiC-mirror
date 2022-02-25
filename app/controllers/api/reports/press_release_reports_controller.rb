# frozen_string_literal: true

module Api
  module Reports
    class PressReleaseReportsController < ApiController

      def index
        render json: Status.multi_task_statuses.map(&:name)
      end

      private


    end
  end
end
