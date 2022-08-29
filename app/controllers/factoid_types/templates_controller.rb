# frozen_string_literal: true

module FactoidTypes
  class TemplatesController < FactoidTypesController
    before_action :update_template, only: %i[update save]

    after_action :send_notification, only: :update, if: -> { @factoid_type.developer.present? }

    def show; end

    def edit; end

    def update; end

    def save; end

    private

    def update_template
      Template.find(params[:id]).update!(template_params)
    end

    def send_notification
      url     = generate_url(@factoid_type)
      channel = @factoid_type.developer.slack_identifier
      message = "The template for <#{url}|Factoid Type ##{@factoid_type.id}> has been updated by #{@current_account.name}." \
                ' Pay attention and make needed changes in the creation method.'

      ::SlackNotificationJob.new.perform(channel, message)
    end

    def template_params
      params.require(:template).permit(:body)
    end
  end
end
