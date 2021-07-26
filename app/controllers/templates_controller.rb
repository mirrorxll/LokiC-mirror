# frozen_string_literal: true

class TemplatesController < ApplicationController
  before_action :render_403, except: :show, if: :developer?
  before_action :update_template, only: %i[update save]

  def show; end

  def edit; end

  def update; end

  def save; end

  private

  def update_template
    Template.find(params[:id]).update(template_params)
  end

  def template_params
    params.require(:template).permit(:body)
  end
end
