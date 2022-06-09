# frozen_string_literal: true

module Accounts
  class BranchAccessLevelsController < AccountsController
    before_action :find_account
    before_action :find_branch_access_level

    def create
      if @branch_access_level.enabled
        flash.now[:error] = { branch: 'already enabled' }
      else
        @branch_access_level.update(enabled: true)
      end

      render 'card'
    end

    def update

    end

    def destroy
      if @branch_access_level.enabled
        @branch_access_level.update(enabled: false)
      else
        flash.now[:error] = { branch: 'already disabled' }
      end

      render 'card'
    end

    private

    def find_branch_access_level
      @branch_access_level =
        @account.branch_access_levels.find_by(branch_id: params[:branch_id] || params[:id])
    end
  end
end
