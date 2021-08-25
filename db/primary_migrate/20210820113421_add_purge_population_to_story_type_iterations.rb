# frozen_string_literal: true

class AddPurgePopulationToStoryTypeIterations < ActiveRecord::Migration[6.0]
  def change
    add_column :story_type_iterations, :purge_population,
               :boolean, after: :population_args
  end
end
