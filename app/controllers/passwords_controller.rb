# frozen_string_literal: true

class PasswordsController < Devise::SessionsController # :nodoc:
  skip_before_action :find_story
end
