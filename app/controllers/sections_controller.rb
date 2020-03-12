# frozen_string_literal: true

class SectionsController < ApplicationController # :nodoc:
  before_action :find_section

  def include
    render_400 && return if @story_type.sections.exists?(@section.id)

    @story_type.sections << @section
  end

  def exclude
    render_400 && return unless @story_type.sections.exists?(@section.id)

    @story_type.sections.destroy(@section)
  end

  private

  def find_section
    @section = Section.find(params[:id])
  end
end
