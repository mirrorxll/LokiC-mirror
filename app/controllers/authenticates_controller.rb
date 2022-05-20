# frozen_string_literal: true

class AuthenticatesController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  before_action :redirect_to_root, if: :current_account

  private

  def find_account_by_email
    @account = Account.find_by(email: params[:email])
  end

  def find_account_by_reset_token
    @account = Account.find_by(reset_password_token: params[:token])
  end

  def redirect_to_root
    redirect_to root_path
  end
end
