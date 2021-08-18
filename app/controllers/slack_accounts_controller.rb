# frozen_string_literal: true

class SlackAccountsController < ApplicationController
  skip_before_action :find_parent_article_type
  skip_before_action :set_article_type_iteration

  before_action :render_403, if: :editor?

  def sync
    SlackAccountsJob.perform_later
  end
end
