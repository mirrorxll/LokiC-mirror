# frozen_string_literal: true

module Api
  module WorkRequests
    class WorkTypesController < ApiController
      def find_or_create
        work_type = WorkType.find_or_create_by!(work_type_param)

        render json: { work_id: work_type.id, work_name: work_type.name }
      end

      private

      def work_type_param
        params.require(:type_of_work).permit(:name).merge({ work: 1 })
      end
    end
  end
end
