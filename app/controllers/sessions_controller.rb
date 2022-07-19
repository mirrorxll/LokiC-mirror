# frozen_string_literal: true

class SessionsController < Devise::SessionsController # :nodoc:
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  def new
    super { flash_adaptation }
  end

  def create
    super { flash_adaptation }
  end

  private

  def flash_adaptation
    %i[notice alert].each do |key|
      next unless flash[key].present?

      message = flash[key]
      flash.delete(key)
      flash[key.eql?(:notice) ? :success : :error] = { authentication: message }
    end
  end
end
