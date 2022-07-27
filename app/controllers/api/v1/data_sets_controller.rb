# frozen_string_literal: true

module Api
  module V1
    class DataSetsController < ApiController
      private

      def find_data_set
        @data_set = DataSet.find(params[:data_set_id] || params[:id])
      end
    end
  end
end
