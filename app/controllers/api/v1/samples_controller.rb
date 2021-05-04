# frozen_string_literal: true

module Api
  module V1
    class SamplesController < ApiController
      before_action :find_sample

      def update
        @sample.update(sample_params)
      end

      private

      def find_sample
        @sample = Sample.find(params[:id])
      end

      def sample_params
        params.require(:samples).permit(:show)
      end
    end
  end
end
