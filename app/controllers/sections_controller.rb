# frozen_string_literal: true

class SectionsController < ApplicationController # :nodoc:
  before_action :find_section

  def include
    render_400 && return if @story.sections.exists?(@section.id)

    @story.sections << @section
  end

  def exclude
    render_400 && return unless @story.sections.exists?(@section.id)

    @story.sections.destroy(@section)
  end

  private

  def find_section
    @section = Section.find(params[:id])
  end
end
