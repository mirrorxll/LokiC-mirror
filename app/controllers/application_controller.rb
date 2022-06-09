# frozen_string_literal: true

require 'action_text'

class ApplicationController < ActionController::Base
  helper ActionText::Engine.helpers
  helper_method :current_account

  before_action :authenticate_user!

  before_action :find_parent_story_type
  before_action :set_story_type_iteration
  before_action :find_parent_article_type
  before_action :set_article_type_iteration

  before_action :unconfirmed_multitasks

  private

  def authenticate_user!
    return unless ((cookies.encrypted[:remember_me] || session[:auth_token]) && current_account).nil?

    cookies.delete(:remember_me)
    session[:auth_token] = nil
    redirect_to sign_in_path
  end

  def current_account
    @current_account ||= Account.find_by(auth_token: cookies.encrypted[:remember_me] || session[:auth_token])
  end
  helper_method :current_account
  impersonates :account

  def find_parent_story_type
    @story_type = StoryType.find(params[:story_type_id])
  end

  def find_parent_article_type
    @factoid_type = ArticleType.find(params[:article_type_id])
  end

  def set_story_type_iteration
    @iteration =
      if params[:iteration_id]
        StoryTypeIteration.find(params[:iteration_id])
      else
        @story_type.iteration
      end
  end

  def set_article_type_iteration
    @iteration =
      if params[:iteration_id]
        ArticleTypeIteration.find(params[:iteration_id])
      else
        @factoid_type.iteration
      end
  end

  def staging_table_action(&block)
    flash.now[:staging_table] =
      if @staging_table.nil? || StagingTable.not_exists?(@staging_table.name)
        @story_type.update!(staging_table_attached: nil, current_account: @current_account)
        @staging_table&.destroy
        staging_table_deleted
      else
        block.call
      end
  rescue StandardError => e
    flash.now[:staging_table] = e.message
  end

  def staging_table_deleted
    'The Table for this story type has been dropped. Please update the page'
  end

  def record_to_change_history(model, event, note, account)
    model.change_history.create!(event: event, note: note, account: account)
  end

  def record_to_alerts(model, subtype, message)
    model.alerts.create!(subtype: subtype.downcase, message: message)
  end

  # this respond to methods like:
  # render_400
  # render_403_dev
  # and render HTTP status
  def method_missing(method_name, *arguments, &block)
    super unless method_name.to_s[/render_([0-9]+)/]

    code = method_name.to_s.match(/render_([0-9]+)/).captures.first.to_i
    render json: Rack::Utils::HTTP_STATUS_CODES[code], status: code
  end

  def respond_to_missing?(method_name, include_private = false)
    !!method_name.to_s[/render_([0-9]+)/] || super
  end

  def send_to_action_cable(story_type, section, message)
    StoryTypeChannel.broadcast_to(story_type, { spinner: true, section: section, message: message })
  end

  def template_with_expired_revision
    @iteration.story_type.template.expired_revision?
  end

  def generate_url(model)
    host = Rails.env.production? ? 'https://lokic.locallabs.com' : 'http://localhost:3000'
    "#{host}#{Rails.application.routes.url_helpers.send("#{model.class.to_s.underscore}_path", model)}"
  end

  def unconfirmed_multitasks
    tasks = Task.ongoing.joins(:assignment_to).where(
      'task_assignments.confirmed': false,
      'task_assignments.account_id': current_account
    )

    flash.now[:warning] = tasks.each_with_object({ unconfirmed_multitask: [] }) do |task, warnings|
      warnings[:unconfirmed_multitask] << view_context.link_to(
        "#{task.title} assigned to you by #{task.creator.name}",
        multi_task_path(task)
      ).html_safe
    end
  end
end
