# frozen_string_literal: true

module FactoidTypes
  class IterationsController < FactoidTypesController
    skip_before_action :set_factoid_type_iteration

    before_action :find_iteration, only: %i[show update apply purge]
    before_action :find_staging_table, only: :purge

    def show
      @factoid_type = @iteration.factoid_type

      render 'factoid_types/main/show'
    end

    def create
      @iteration = @factoid_type.iterations.create!(iteration_params)

      @factoid_type.update!(current_iteration: @iteration, current_account: @current_account)
      @factoid_type.staging_table&.default_iter_id

      redirect_to @factoid_type
    end

    def update
      @iteration.update!(iteration_params)
    end

    def apply
      @factoid_type.update!(current_iteration: @iteration, current_account:@current_account)
      @factoid_type.staging_table&.default_iter_id

      redirect_to @factoid_type
    end

    def purge
      staging_table_action { @staging_table.purge_current_iteration }

      if flash.now[:error].nil?
        @story_type.update!(export_configurations_created: nil, current_account:@current_account)
        @iteration.stories.destroy_all
        @iteration.auto_feedback.destroy_all

        @iteration.update!(
          population: nil, samples: nil,
          creation: nil, schedule: nil, export: nil,
          current_account:@current_account
        )
      end

      render 'factoid_types/main/show'
    end

    private

    def find_iteration
      @iteration = FactoidTypeIteration.find(params[:id])
    end

    def find_staging_table
      @staging_table = @story_type.staging_table
    end

    def iteration_params
      permitted = params.require(:iteration).permit(:name)

      {
        name: permitted[:name],
        current_account:@current_account
      }
    end
  end
end
