# frozen_string_literal: true

module FactoidTypes
  class DataSetsController < FactoidTypesController
    before_action :find_current_data_set

    def update
      @factoid_type.update!(change_data_set_params)
    end

    private

    def change_data_set_params
      attrs = params.require(:factoid_type).permit(:data_set_id)
      attrs[:current_account] = current_account
      attrs
    end

    def find_current_data_set
      data_set_id = params[:current_data_set_page_id].present? ? params[:current_data_set_page_id] : params[:factoid_type][:data_set_id]
      @current_data_set = DataSet.find(data_set_id)
    end
  end
end

