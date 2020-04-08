# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController # :nodoc:
  skip_before_action :find_story_type

  def new
    flash[:alert] = 'Registration disabled'
    redirect_to new_account_session_path
  end
end
