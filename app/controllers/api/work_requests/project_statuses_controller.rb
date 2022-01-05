module Api
  module WorkRequests
    class ProjectStatusesController < ApiController
      before_action :find_work_request

      def all_deleted
        deleted = @work_request.projects.all? { |p| p.status.name.eql?('deleted') }

        render json: { all_deleted: deleted }
      end

      private

      def find_work_request
        @work_request = WorkRequest.find(params[:id])
      end
    end
  end
end
