# frozen_string_literal: true

module StoryTypes
  class DataSetsController < StoryTypesController
    before_action :find_current_data_set

    def update
      @story_type.update!(change_data_set_params)
    end

    private

    def change_data_set_params
      attrs = params.require(:story_type).permit(:data_set_id)
      attrs[:current_account] = current_account
      attrs
    end

    def find_current_data_set
      @current_data_set = DataSet.find(params[:current_data_set_page_id])
    end
  end
end
