# frozen_string_literal: true

module WorkRequests
  class ArchivesController < WorkRequestsController
    before_action :find_work_request

    def update
      @work_request.update!(archived: params[:archived])
    end
  end
end
