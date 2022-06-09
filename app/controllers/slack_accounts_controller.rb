# frozen_string_literal: true

class SlackAccountsController < ApplicationController
  skip_before_action :find_parent_article_type
  skip_before_action :set_article_type_iteration

  def sync
    SlackAccountsJob.perform_async
  end
end
