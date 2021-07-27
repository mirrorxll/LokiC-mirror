# frozen_string_literal: true

class DevelopersController < ApplicationController
  before_action :render_403, if: :developer?
  before_action :find_developer, only: :include
  after_action  :send_notification, only: :include
  after_action  :distributed_to_history, only: :include

  def include
    render_403 && return if @story_type.developer

    @story_type.update!(developer: @developer, distributed_at: Time.now)
  end

  def exclude
    render_403 && return unless @story_type.developer

    @story_type.update(developer: nil, distributed_at: nil)
  end

  private

  def find_developer
    @developer = Account.find(params[:id])
  end

  def send_notification
    return if @developer.slack.nil? || @developer.slack.deleted

    message = "*[ LokiC ] <#{story_type_url(@story_type)}|STORY TYPE ##{@story_type.id}> | "\
              "DISTRIBUTED TO YOU*\n>#{@story_type.name}"

    SlackNotificationJob.perform_later(@developer.slack.identifier, message)
  end

  def distributed_to_history
    note = "distributed to #{@developer.name}"
    record_to_change_history(@story_type, 'distributed', note, current_account)
  end
end
