# frozen_string_literal: true

module ArticleTypes
  class TemplatesController < ApplicationController
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration

    before_action :render_403, except: :show, if: :developer?
    before_action :update_template, only: %i[update save]

    def show; end

    def edit; end

    def update; end

    def save; end

    private

    def update_template
      Template.find(params[:id]).update!(template_params)
    end

    def template_params
      params.require(:template).permit(:body)
    end
  end
end
