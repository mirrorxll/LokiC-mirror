# frozen_string_literal: true

module DataSets
  class SheriffsController < DataSetsController
    before_action :find_data_set
    before_action :find_sheriff, only: :update

    def show; end

    def edit
      @sheriffs = AccountRole.find_by(name: 'Content Data Cleaner').accounts
    end

    def update
      if @sheriff.nil? || @sheriff.roles.find_by(name: 'Content Data Cleaner')
        @data_set.update(sheriff: @sheriff)
      else
        flash.now[:error] = { sheriff: :error }
      end

      render 'data_sets/sheriffs/show'
    end

    private

    def find_sheriff
      @sheriff = Account.find_by(id: params[:sheriff][:id])
    end
  end
end
