# frozen_string_literal: true

class SessionsController < Devise::SessionsController # :nodoc:
  skip_before_action :find_story
end
