# frozen_string_literal: true

class TemplatesController < ApplicationController
  before_action :render_400, if: :developer?

  def edit; end

  def update
    @story_type.template.update(template_params)
  end

  private

  def template_params
    params.require(:template).permit(:body)
  end
end
