# frozen_string_literal: true

class SlackAccountsController < ApplicationController
  def sync
    SlackAccountsJob.perform_async
  end
end
