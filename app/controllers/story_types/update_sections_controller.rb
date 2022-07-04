# frozen_string_literal: true

module StoryTypes
  class UpdateSectionsController < StoryTypesController
    before_action :message

    def update; end

    private

    def message
      @key = params[:message][:key].to_sym
      flash.now[@key] = params[:message][@key]
    end
  end
end
