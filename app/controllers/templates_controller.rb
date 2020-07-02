# frozen_string_literal: true

class TemplatesController < ApplicationController
  def edit; end

  def update
    @story_type.template.update(template_params)
  end

  private

  def template_params
    params.require(:template).permit(:body)
  end
end
