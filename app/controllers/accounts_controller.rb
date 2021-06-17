class AccountsController < ApplicationController
  before_action :authenticate_account!
  skip_before_action :find_parent_story_type
  skip_before_action :set_iteration

  def index
    @accounts = Account.order(:id).includes(:account_types)
  end

  def impersonate
    account = Account.find(params[:id])
    impersonate_account(account)
    redirect_to root_path
  end

  def stop_impersonating
    stop_impersonating_account
    redirect_to root_path
  end
end
