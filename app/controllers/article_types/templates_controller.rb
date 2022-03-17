# frozen_string_literal: true

module ArticleTypes
  class TemplatesController < ApplicationController
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration

    before_action :render_403, except: :show, if: :developer?
    before_action :update_template, only: %i[update save]

    after_action :send_notification, only: :update, if: -> { @article_type.developer.present? }

    def show; end

    def edit; end

    def update; end

    def save; end

    private

    def update_template
      Template.find(params[:id]).update!(template_params)
    end

    def send_notification
      url     = generate_url(@article_type)
      channel = @article_type.developer.slack_identifier
      message = "The template for <#{url}|Factoid Type ##{@article_type.id}> has been updated by #{current_account.name}." \
                ' Pay attention and make needed changes in the creation method.'

      ::SlackNotificationJob.perform_now(channel, message)
    end

    def template_params
      params.require(:template).permit(:body)
    end
  end
end
