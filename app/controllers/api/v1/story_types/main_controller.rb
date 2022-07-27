# frozen_string_literal: true

module Api
  module V1
    module StoryTypes
      class MainController < StoryTypesController
        def index
          render json: StoryType.all.map(&:name) if params[:names]
        end
      end
    end
  end
end
