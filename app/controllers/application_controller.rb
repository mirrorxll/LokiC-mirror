# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_account!
  before_action :find_parent_story_type
  before_action :set_iteration
  impersonates :account

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_in, keys: %i[email password remember_me]
    devise_parameter_sanitizer.permit :account_update, keys: %i[email first_name last_name password password_confirmation current_password]
  end

  def find_parent_story_type
    @story_type = StoryType.find(params[:story_type_id])
  end

  def set_iteration
    @iteration =
      if params[:iteration_id]
        Iteration.find(params[:iteration_id])
      else
        @story_type.iteration
      end
  end

  def manager?
    current_account.types.include?('manager')
  end

  def editor?
    current_account.types.include?('editor')
  end

  def developer?
    current_account.types.eql?(['developer'])
  end

  def scraper?
    current_account.types.eql?(['scraper'])
  end

  def only_scraper?
    acc_types = current_account.types
    acc_types.count.eql?(1) && acc_types.first.eql?('scraper')
  end

  def staging_table_action(&block)
    flash.now[:staging_table] =
      if @staging_table.nil? || StagingTable.not_exists?(@staging_table.name)
        @story_type.update(staging_table_attached: nil)
        @staging_table&.destroy
        detached_or_delete
      else
        block.call
      end
  rescue StandardError => e
    flash.now[:staging_table] = e.message
  end

  def detached_or_delete
    'The Table for this story type has been renamed, detached or drop. Please update the page.'
  end

  def record_to_change_history(model, event, message)
    model.change_history.create!(event: event, body: message)
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
end
