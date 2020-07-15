# frozen_string_literal: true

class FactCheckingDocsController < ApplicationController
  before_action :find_fcd, except: :template

  def show; end

  def edit; end

  def update
    if @fcd.update(fcd_params)
      redirect_to story_type_fact_checking_doc_path(@story_type, @fcd)
    else
      render :edit
    end
  end

  def template
    @template = @story_type.template
  end

  private

  def find_fcd
    @fcd = @story_type.fact_checking_doc
  end

  def fcd_params
    params.require(:fact_checking_doc).permit(:body)
  end
end
