# frozen_string_literal: true

module Accounts
  class ImpersonatesController < AccountsController
    before_action :find_account, only: :create

    def create
      impersonate_account(@account)
      redirect_back fallback_location: root_path
    end

    def destroy
      stop_impersonating_account
      redirect_back fallback_location: root_path
    end
  end
end
