# frozen_string_literal: true

class DevelopersController < ApplicationController
  before_action :render_400, if: :developer?
  before_action :find_developer, only: :include
  after_action  :send_notification, only: :include

  def include
    render_400 && return if @story_type.developer

    @story_type.update!(developer: @developer)
  end

  def exclude
    render_400 && return unless @story_type.developer

    @story_type.update(developer: nil)
  end

  private

  def find_developer
    @developer = Account.find(params[:id])
  end

  def send_notification
    return if @developer.slack.nil? || @developer.slack.deleted

    SlackNotificationJob.perform_later(
      @developer.slack.identifier,
      "*[ LokiC ] STORY TYPE ##{@story_type.id} | DISTRIBUTED TO YOU*\n>"\
      "<#{story_type_url(@story_type)}| #{@story_type.name}>"
    )
  end
end
