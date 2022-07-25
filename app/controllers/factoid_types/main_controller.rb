# frozen_string_literal: true

module FactoidTypes
  class MainController < FactoidTypesController
    before_action :find_data_set,              only: %i[new create]
    before_action :find_factoid_type,          except: %i[index new create]
    before_action :set_factoid_type_iteration, except: %i[index new create]

    before_action :grid_lists, only: %i[index show]
    before_action :current_list, only: :index
    before_action :generate_grid, only: :index

    def index
      @tab_title = 'LokiC :: FactoidTypes'
    end

    def show
      @tab_title = "LokiC :: FactoidTypes ##{@factoid_type.id} <#{@factoid_type.name}>"
    end

    def update
      @factoid_type.update!(exist_factoid_type_params)
    end

    private

    def grid_lists
      @lists = HashWithIndifferentAccess.new

      @lists['all'] = {}     if @permissions['grid']['all']
      @lists['archived'] = { archived: true } if @permissions['grid']['archived']
    end

    def current_list
      keys = @lists.keys
      @current_list = keys.include?(params[:list]) ? params[:list] : keys.first
    end

    def generate_grid
      return unless @current_list

      grid_params = request.parameters[:factoid_types_grid] || {}
      grid_params.merge!({ current_account: current_account, env: env })

      @grid = FactoidTypesGrid.new(grid_params) { |scope| scope.where(@lists[@current_list]) }
      @grid.scope { |sc| sc.page(params[:page]).per(30) }
    end

    def find_data_set
      @data_set = DataSet.find(params[:data_set_id])
    end

    def env
      %w[development test].include?(Rails.env) ? 'staging' : Rails.env
    end

    def exist_factoid_type_params
      attrs = params.require(:factoid_type).permit(:name,
                                                   :kind_id,
                                                   :topic_id,
                                                   :source_type,
                                                   :source_name,
                                                   :source_link,
                                                   :original_publish_date).reject { |_, v| v.blank? }
      attrs[:current_account] = current_account
      attrs
    end
  end
end
