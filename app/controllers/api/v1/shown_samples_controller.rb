# frozen_string_literal: true

module Api
  module V1
    class ShownSamplesController < ApiController
      before_action :find_sample

      def update
        show =
          if params[:commit].eql?('show') && show_samples_count < 3
            true
          elsif params[:commit].eql?('hide')
            false
          end

        @sample.update!(show: show) unless show.nil?
      end

      private

      def find_sample
        @sample = Sample.find(params[:id])
      end

      def show_samples_count
        @sample.iteration.show_samples.count
      end
    end
  end
end
