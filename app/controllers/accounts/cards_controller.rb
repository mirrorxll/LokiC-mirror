# frozen_string_literal: true

module Accounts
  class CardsController < AccountsController
    before_action :find_account
    before_action :find_card

    def create
      if @card.enabled
        flash.now[:error] = { branch: 'already enabled' }
      else
        @card.update(enabled: true)
        create_ordered_lists
      end

      render 'card'
    end

    def update
      if @card.update(access_level_params)
        clear_ordered_lists
        create_ordered_lists
      else
        flash.now[:error] = { branch: 'check attributes' }
      end
    end

    def destroy
      if @card.enabled
        @card.update(enabled: false)
        clear_ordered_lists
      else
        flash.now[:error] = { branch: 'already disabled' }
      end

      render 'card'
    end

    private

    def create_ordered_lists
      @card.access_level.permissions['grid'].each_with_index do |grid, i|
        @account.ordered_lists << OrderedList.create(branch_name: @card.access_level.branch.name, grid_name: grid.first, position: i) if grid.last
      end
    end

    def clear_ordered_lists
      @account.ordered_lists.where(branch_name: @card.branch.name).destroy_all
    end

    def find_card
      @card = @account.cards.find(params[:card_id] || params[:id])
    end

    def access_level_params
      params.require(:card).permit(:access_level_id)
    end
  end
end
