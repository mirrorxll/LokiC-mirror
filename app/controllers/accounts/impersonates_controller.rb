# frozen_string_literal: true

module Accounts
  class ImpersonatesController < AccountsController
    def create
      if current_account.types.include?('manager')
        impersonate_account Account.find(params[:id])
      end
      redirect_to root_path
    end

    def destroy
      stop_impersonating_account
      redirect_to root_path
    end
  end
end
