# frozen_string_literal: true

class SlackAccountsController < ApplicationController
  def sync
    SlackAccountsJob.perform_later
  end
end
