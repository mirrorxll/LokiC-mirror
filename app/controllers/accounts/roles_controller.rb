# frozen_string_literal: true

module Accounts
  class RolesController < AccountsController
    def index

    end

    def new

    end

    def create
    end

    def destroy
      stop_impersonating_account
      redirect_to root_path
    end
  end
end
