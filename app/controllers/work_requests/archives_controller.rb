# frozen_string_literal: true

module WorkRequests
  class ArchivesController < WorkRequestsController
    before_action :find_work_request

    def update
      @request.update!(archived: params[:archived])
    end
  end
end
