# frozen_string_literal: true

module Api
  module V1
    module DataSets
      class MainController < DataSetsController
        def index
          render json: DataSet.all.map(&:name) if params[:names]
        end
      end
    end
  end
end
