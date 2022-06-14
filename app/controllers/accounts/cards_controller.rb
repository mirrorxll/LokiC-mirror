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
      end

      render 'card'
    end

    def destroy
      if @card.enabled
        @card.update(enabled: false)
      else
        flash.now[:error] = { branch: 'already disabled' }
      end

      render 'card'
    end

    private

    def find_card
      @card = @account.cards.find(params[:card_id] || params[:id])
    end
  end
end
