# frozen_string_literal: true

module FactoidRequests
  class TemplatesController < FactoidRequestsController
    before_action :find_factoid_request

    def update
      @factoid_request.public_send("template_#{params[:id]}_body").update!(body: template_body_params)
      @factoid_request.public_send("template_#{params[:id]}_assoc").update!(body: template_assoc_params)
    end

    private

    def template_body_params
      params.require(:factoid_request).permit(:"template_#{params[:id]}_body").values.first
    end

    def template_assoc_params
      params.require(:factoid_request).permit(:"template_#{params[:id]}_assoc").values.first
    end
  end
end

