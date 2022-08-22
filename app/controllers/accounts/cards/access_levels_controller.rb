# frozen_string_literal: true

module Accounts
  module Cards
    class AccessLevelsController < CardsController
      before_action :find_access_level, only: %i[show edit update]

      def show; end

      def new
        @access_level_template =
          @card.branch.access_levels.find_by(name: 'manager').permissions
      end

      def create
        @access_level = AccessLevel.new(new_access_level_params)
        @access_level.update(permissions: HashValuesTrueFalse.convert(@access_level.permissions))

        @card.update(access_level: @access_level) if @access_level.errors.none?
      end

      def edit; end

      def update
        @access_level.update(edit_access_level_params)
        @access_level.update(permissions: HashValuesTrueFalse.convert(@access_level.permissions))
      end

      private

      def find_access_level
        @access_level = AccessLevel.find(params[:id])
      end

      def new_access_level_params
        params.require(:access_level).permit(:branch_id, :name, permissions: {})
      end

      def edit_access_level_params
        params.require(:access_level).permit(:name, permissions: {})
      end
    end
  end
end
