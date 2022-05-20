# frozen_string_literal: true

require 'action_text'

class ApplicationController < ActionController::Base
  helper ActionText::Engine.helpers

  impersonates :account

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_account!

  before_action :find_parent_story_type, unless: :devise_controller?
  before_action :set_story_type_iteration, unless: :devise_controller?
  before_action :find_parent_article_type, unless: :devise_controller?
  before_action :set_article_type_iteration, unless: :devise_controller?

  before_action :check_tasks

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_in, keys: %i[email password remember_me]
    devise_parameter_sanitizer.permit :account_update, keys: %i[email first_name last_name password password_confirmation current_password]
  end

  def find_parent_story_type
    @story_type = StoryType.find(params[:story_type_id])
  end

  def find_parent_article_type
    @article_type = ArticleType.find(params[:article_type_id])
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
        @article_type.iteration
      end
  end

  def manager?
    current_account.types.include?('manager')
  end

  def editor?
    current_account.types.include?('editor')
  end

  def developer?
    current_account.types.include?('developer')
  end

  def scraper?
    current_account.types.include?('scraper')
  end

  def only_scraper?
    acc_types = current_account.types
    acc_types.count.eql?(1) && acc_types.first.eql?('scraper')
  end

  def outside_manager?
    current_account.types.include?('outside manager')
  end

  def client?
    current_account.types.include?('client')
  end

  def guest_1?
    current_account.types.include?('guest-1')
  end

  def guest_2?
    current_account.types.include?('guest-2')
  end

  def staging_table_action(&block)
    flash.now[:staging_table] =
      if @staging_table.nil? || StagingTable.not_exists?(@staging_table.name)
        @story_type.update!(staging_table_attached: nil, current_account: current_account)
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

  def check_tasks
    tasks = Task.ongoing
                .joins(:assignment_to)
                .where('task_assignments.confirmed': false, 'task_assignments.account_id': current_account)
    tasks.each_with_index do |task, i|
      creator                             = "#{task.creator.first_name} #{task.creator.last_name}"
      message                             = "Task #{task.title} assigned to you by #{creator}"
      flash.now["task_notification_#{i}"] = view_context.link_to(message, task).html_safe
    end
  end
end
