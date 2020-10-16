# frozen_string_literal: true

class CodesController < ApplicationController # :nodoc:
  skip_before_action :set_iteration

  before_action :render_400, if: :editor?

  def show
    code = @story_type.code.download
    @ruby_code = CodeRay.scan(code, :ruby).div(line_numbers: :table)
  end

  def create
    render_400 && return if @story_type.code.attached?

    code = @story_type.download_code_from_db
    render_400 && return if code.nil?

    @story_type.code.attach(io: StringIO.new(code), filename: "S#{@story_type.id}.rb")
  end

  def destroy
    @story_type.code.purge if @story_type.code.attached?
  end
end
