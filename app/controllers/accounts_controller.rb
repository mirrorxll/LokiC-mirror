# frozen_string_literal: true

class AccountsController < ApplicationController
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  def index
    @tab_title = 'LokiC :: Accounts'
    @accounts_grid = AccountsGrid.new
  end

  def new

  end

  def create

  end
end
