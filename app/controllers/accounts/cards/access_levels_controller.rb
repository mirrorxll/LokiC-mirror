# frozen_string_literal: true

module Accounts
  module Cards
    class AccessLevelsController < CardsController
      before_action :find_access_level, only: :show

      def show; end

      def new; end

      def create; end

      private

      def find_access_level
        @access_level = AccessLevel.find(params[:id])
      end
    end
  end
end
