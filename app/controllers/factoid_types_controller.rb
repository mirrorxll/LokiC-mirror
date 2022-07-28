# frozen_string_literal: true

class FactoidTypesController < ApplicationController
  before_action -> { authorize!('factoid_types') }

  before_action :find_factoid_type
  before_action :set_factoid_type_iteration

  private

  def find_factoid_type
    @factoid_type = FactoidType.find(params[:factoid_type_id] || params[:id])
  end

  def set_factoid_type_iteration
    @iteration =
      if params[:iteration_id]
        FactoidTypeIteration.find(params[:iteration_id])
      else
        @factoid_type.iteration
      end
  end
end
