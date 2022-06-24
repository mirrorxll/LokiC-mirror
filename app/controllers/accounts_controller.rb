# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action do
    unless true_account.manager?
      flash[:error] = { accounts: :unauthorized }
      redirect_to root_path
    end
  end

  private

  def find_account
    @account = Account.find(params[:account_id] || params[:id])
  end

  def find_status_comment
    @status_comment = @account.status_comment || @account.create_status_comment
  end
end
