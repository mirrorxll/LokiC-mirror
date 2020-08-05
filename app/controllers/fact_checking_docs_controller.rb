# frozen_string_literal: true

class FactCheckingDocsController < ApplicationController
  before_action :find_fcd, except: :template
  before_action :update_fcd, only: %i[update save]

  def show; end

  def edit; end

  def update
    if @fcd.errors.any?
      render :edit
    else
      redirect_to story_type_fact_checking_doc_path(@story_type, @fcd)
    end
  end

  def save; end

  def template
    @template = @story_type.template
  end

  private

  def find_fcd
    @fcd = @story_type.fact_checking_doc
  end

  def update_fcd
    @fcd.update(fcd_params)
  end

  def fcd_params
    params.require(:fact_checking_doc).permit(:body)
  end
end
