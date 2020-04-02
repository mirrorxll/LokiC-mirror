# frozen_string_literal: true

class SessionsController < Devise::SessionsController # :nodoc:
  skip_before_action :find_parent_story_type
end
