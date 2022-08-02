# frozen_string_literal: true

module FactoidTypes
  class DevelopersController < FactoidTypesController
    # skip_before_action :set_factoid_type_iteration

    before_action :find_developer, only: :include

    def include
      render_403 && return if @factoid_type.developer

      @factoid_type.update!(developer: @developer, current_account: current_account)
    end

    def exclude
      render_403 && return unless @factoid_type.developer

      @factoid_type.update!(developer: nil, current_account: current_account)
    end

    private

    def find_developer
      @developer = @factoid_type.developer || Account.find(params[:id])
    end
  end
end
