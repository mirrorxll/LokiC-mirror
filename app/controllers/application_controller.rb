# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_account!
  before_action :find_parent_story_type

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_in, keys: %i[email password remember_me]
    devise_parameter_sanitizer.permit :account_update, keys: %i[name email password password_confirmation]
  end

  def render_400
    render json: { error: 'Bad Request' }, status: 400
  end

  def find_parent_story_type
    @story_type = StoryType.find(params[:story_type_id])
  end
end
