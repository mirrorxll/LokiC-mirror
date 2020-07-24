# frozen_string_literal: true

class SlackAccountsController < ApplicationController
  before_action :render_400, if: :editor?

  def sync
    SlackAccountsJob.perform_later
  end
end
