# frozen_string_literal: true

module Api
  module WorkRequests
    class UnderwritingProjectsController < ApiController
      def find_or_create
        project = UnderwritingProject.find_or_create_by!(project_params)

        render json: { project_id: project.id, project_name: project.name }
      end

      private

      def project_params
        params.require(:project).permit(:name)
      end
    end
  end
end
