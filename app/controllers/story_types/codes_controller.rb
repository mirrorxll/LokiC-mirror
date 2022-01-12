# frozen_string_literal: true

module StoryTypes
  class CodesController < ApplicationController # :nodoc:
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration
    skip_before_action :set_story_type_iteration, only: :show

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
      # @code = @story_type.download_code_from_db
      @code = <<~CODE
        class S1
          def check_updates; end
          def population(options)
          end    
        end
      CODE
    end
  end
end
