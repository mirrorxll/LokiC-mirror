# frozen_string_literal: true

class FactoidTypesController < ApplicationController
  before_action -> { authorize!('factoid_types') }
  before_action -> { authorize!('data_sets', redirect: false) }

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

  def send_to_action_cable(factoid_type, iteration, ft_section, it_section, message)
    FactoidTypeChannel.broadcast_to(factoid_type, { spinner: true, section: ft_section, message: message })
    ExportedFactoidsChannel.broadcast_to(iteration, { spinner: true, section: it_section, message: message })
  end
end
