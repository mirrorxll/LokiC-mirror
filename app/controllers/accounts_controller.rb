class AccountsController < ApplicationController
  before_action :authenticate_account!

  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  def index
    @tab_title = "LokiC :: Accounts"
    @accounts = Account.order(:id).includes(:account_types)
  end

  def impersonate
    if current_account.types.include?('manager')
      account = Account.find(params[:id])
      impersonate_account(account)
    end
    redirect_to root_path
  end

  def stop_impersonating
    stop_impersonating_account
    redirect_to root_path
  end
end
