# frozen_string_literal: true

module ArticleTypes
  class CodesController < ApplicationController # :nodoc:
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration
    skip_before_action :set_article_type_iteration

    before_action :render_403, if: :editor?
    before_action :download_code, only: %i[attach reload]

    def show
      @ruby_code =
        CodeRay.scan(@article_type.code.download, :ruby).div(line_numbers: :table)
    end

    def attach
      render_403 && return if @article_type.code.attached? || @code.nil?

      @article_type.code.attach(io: StringIO.new(@code), filename: "A#{@article_type.id}.rb")
    end

    def reload
      render_403 && return if @code.nil?

      @article_type.code.purge
      @article_type.code.attach(io: StringIO.new(@code), filename: "A#{@article_type.id}.rb")
    end

    private

    def download_code
      @code = @article_type.download_code_from_db
    end
  end
end
