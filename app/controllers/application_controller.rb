# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_account!
  before_action :find_parent_story_type
  before_action :set_iteration

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
        @story_type.current_iteration
      end
  end

  def manager?
    current_account.type.eql?('manager')
  end

  def editor?
    current_account.type.eql?('editor')
  end

  def developer?
    current_account.type.eql?('developer')
  end

  def render_400
    render json: { error: 'Bad Request' }, status: 400
  end
  alias render_400_developer render_400
  alias render_400_editor    render_400

  def staging_table_action(&block)
    flash.now[:error] =
      if @staging_table.nil? || StagingTable.not_exists?(@staging_table.name)
        @staging_table&.destroy
        detached_or_delete
      else
        block.call
      end
  rescue StandardError => e
    flash.now[:error] = e.message
  end

  def detached_or_delete
    'The Table for this story type has been renamed, detached or drop. Please update the page.'
  end


end
