# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_account!
  before_action :find_parent_story_type

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_in, keys: %i[email password remember_me]
    devise_parameter_sanitizer.permit :account_update, keys: %i[first_name last_name slack_account_id email password password_confirmation]
  end

  def find_parent_story_type
    @story_type = StoryType.find(params[:story_type_id])
  end

  def manager?
    current_account.type.eql?('manager')
  end

  def editor?
    puts 'НЕУДАЧНИК'
    puts 'НЕУДАЧНИК'
    puts 'НЕУДАЧНИК'
    puts 'НЕУДАЧНИК'
    puts 'НЕУДАЧНИК'
    puts 'НЕУДАЧНИК'
    puts 'НЕУДАЧНИК'
    puts 'НЕУДАЧНИК'
    puts 'НЕУДАЧНИК'
    puts 'НЕУДАЧНИК'
    puts 'НЕУДАЧНИК'
    puts 'НЕУДАЧНИК'
    puts 'НЕУДАЧНИК'
    puts 'НЕУДАЧНИК'
    puts 'НЕУДАЧНИК'

    current_account.type.eql?('editor')
  end

  def developer?
    current_account.type.eql?('developer')
  end

  def render_400
    render json: { error: 'Bad Request' }, status: 400
  end
end
