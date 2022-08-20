# frozen_string_literal: true

require 'action_text'

class ApplicationController < ActionController::Base
  helper ActionText::Engine.helpers
  helper_method :current_account

  before_action :authenticate_account!
  before_action :unconfirmed_multi_tasks

  private

  def authenticate_account!
    return unless ((cookies.encrypted[:remember_me] || session[:auth_token]) && current_account).nil?

    cookies.delete(:remember_me)
    session[:auth_token] = nil
    session[:return_to] = request.fullpath
    redirect_to sign_in_path
  end

  def current_account
    @current_account ||= Account.find_by(auth_token: cookies.encrypted[:remember_me] || session[:auth_token])
  end
  impersonates :account

  # callback authorize! called for 'work_requests', 'factoid_requests',
  # 'multi_tasks', 'scrape_tasks', 'data_sets', 'story_types', 'factoid_types'
  def authorize!(branch_name, redirect: true)
    account_card = current_account.cards.find_by(branch: Branch.find_by(name: branch_name))

    if account_card.enabled
      instance_variable_set("@#{branch_name}_permissions", account_card.access_level.permissions)
    elsif redirect
      flash[:error] = { "#{branch_name}": :unauthorized }
      redirect_to root_path
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

  def generate_url(model)
    host =
      case Rails.env
      when 'production'
        'https://lokic.locallabs.com'
      when 'staging'
        'https://lokic-staging.locallabs.com'
      else
        'http://localhost:3000'
      end

    "#{host}#{Rails.application.routes.url_helpers.send("#{model.class.to_s.underscore}_path", model)}"
  end

  def unconfirmed_multi_tasks
    return if cookies[:unconfirmed_multitask_toasts_lock]

    cookies.encrypted[:unconfirmed_multitask_toasts_lock] = {
      value: true,
      expires: DateTime.now + 15.minute
    }

    tasks = MultiTask.ongoing.joins(:assignment_to).where.not(creator: current_account).where(
      'task_assignments.confirmed': false,
      'task_assignments.account_id': current_account
    )

    flash.now[:warning] = tasks.each_with_object({ unconfirmed_multi_task: [] }) do |task, warnings|
      warnings[:unconfirmed_multi_task] << view_context.link_to(
        "#{task.title} assigned to you by #{task.creator.name}",
        multi_task_path(task)
      ).html_safe
    end
  end
end
