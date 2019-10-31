# frozen_string_literal: true

class ApplicationController < ActionController::Base # :nodoc:
  before_action :authenticate_user!

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_in, keys: %i[email password remember_me]
    devise_parameter_sanitizer.permit :account_update, keys: %i[name email password password_confirmation]
  end
end
