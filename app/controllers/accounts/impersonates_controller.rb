# frozen_string_literal: true

module Accounts
  class ImpersonatesController < AccountsController
    def create
      impersonate_account Account.find(params[:account_id])
      redirect_back fallback_location: root_path
    end

    def destroy
      stop_impersonating_account
      redirect_back fallback_location: root_path
    end
  end
end
