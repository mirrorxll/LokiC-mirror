# frozen_string_literal: true

class CodesController < ApplicationController # :nodoc:
  skip_before_action :set_iteration, only: :show

  before_action :render_403, if: :editor?
  before_action :download_code, only: %i[attach reload]

  def show
    @ruby_code =
      CodeRay.scan(@story_type.code.download, :ruby).div(line_numbers: :table)
  end

  def attach
    render_403 && return if @story_type.code.attached? || @code.nil?

    @story_type.code.attach(io: StringIO.new(@code), filename: "S#{@story_type.id}.rb")
  end

  def reload
    render_403 && return if @code.nil?

    @story_type.code.purge
    @story_type.code.attach(io: StringIO.new(@code), filename: "S#{@story_type.id}.rb")
  end

  private

  def download_code
    @code = @story_type.download_code_from_db
  end
end
