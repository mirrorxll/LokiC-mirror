# frozen_string_literal: true

module Accounts
  module Cards
    class AccessLevelsController < CardsController
      before_action :find_access_level

      def edit; end

      private

      def find_access_level
        p @access_level = AccessLevel.find(params[:id])
      end
    end
  end
end
