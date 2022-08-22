# frozen_string_literal: true

class AuthenticatesController < ApplicationController
  before_action :redirect_to_root, if: :current_account

  private

  def find_account_by_email
    @account = Account.find_by(email: params[:email])
  end

  def redirect_to_root
    redirect_to root_path
  end
end
