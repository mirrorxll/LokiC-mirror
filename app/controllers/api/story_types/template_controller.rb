# frozen_string_literal: true

module Api
  module StoryTypes
    class TemplateController < ApiController
      before_action :find_story_type

      def update
        render json: { success: @story_type.template.update(template_params) }
      end

      private

      def find_story_type
        @story_type = StoryType.find(params[:story_type_id])
      end

      def template_params
        params.require(:template).permit(:body, :static_year, :revision)
      end
    end
  end
end
