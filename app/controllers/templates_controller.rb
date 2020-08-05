# frozen_string_literal: true

class TemplatesController < ApplicationController
  before_action :render_400, if: :developer?
  before_action :update_template, only: %i[update save]

  def edit; end

  def update; end

  def save; end

  private

  def update_template
    @story_type.template.update(template_params)
  end

  def template_params
    params.require(:template).permit(:body)
  end
end
