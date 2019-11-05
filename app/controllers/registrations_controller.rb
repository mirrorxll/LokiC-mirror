# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController # :nodoc:
  def new
    flash[:alert] = 'Registration disabled'
    redirect_to new_user_session_path
  end
end
