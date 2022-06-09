# frozen_string_literal: true

class AccountsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  private

  def find_account
    @account = Account.find(params[:account_id] || params[:id])
  end

  def find_status_comment
    @status_comment = @account.status_comment || @account.create_status_comment
  end
end
